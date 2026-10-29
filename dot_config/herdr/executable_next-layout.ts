#!/usr/bin/env bun
// prefix Space for herdr: cycle the focused tab through a few even-sized layouts, keeping every pane
// and its running process.
//
//   2 panes: side by side <-> stacked
//   3 panes: main on top <-> main on the left (the other two share the rest)
//   4 panes: main on top -> main on the left -> 2x2 grid
//   any other count: nothing happens
//
// herdr has no call that changes a split's direction in place, so the tab is rebuilt: every pane but
// the target tree's first leaf moves out to one scratch tab, then moves back in top-down, each split
// created next to the leaf it subdivides. The scratch tab closes once its last pane moves back.
//
// herdr remembers no "current layout", so the current one is recognised from the tree's structure
// (directions only, so a resized layout is still recognised); anything else starts the cycle.

enum SplitDirection {
  Right = "right",
  Down = "down",
}

const HALF = 0.5;
const REQUEST_ID = "next-layout";

type PaneNode = { type: "pane"; pane_id: string };
type SplitNode = {
  type: "split";
  direction: SplitDirection;
  ratio: number;
  first: LayoutNode;
  second: LayoutNode;
};
type LayoutNode = PaneNode | SplitNode;
type LayoutBuilder = (paneIds: string[]) => LayoutNode;

type LayoutExportResult = { layout: { root: LayoutNode } };
type PaneMoveResult = { move_result: { pane: { tab_id: string } } };

const socketPath = requireEnv("HERDR_SOCKET_PATH");
const tabId = requireEnv("HERDR_ACTIVE_TAB_ID");
const focusedPaneId = requireEnv("HERDR_ACTIVE_PANE_ID");

function requireEnv(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`${name} is not set; run this from a herdr custom command`);
  return value;
}

// herdr serves one request per connection, and its first read of a new connection sleeps 100 ms
// when nothing has arrived yet. Bun.connect sends the line in the same tick the socket opens, so the
// request is already there; node:net's socket lands late and pays that sleep on every call.
async function request<T>(method: string, params: Record<string, unknown>): Promise<T> {
  const { promise, resolve, reject } = Promise.withResolvers<T>();
  let buffer = "";
  await Bun.connect({
    unix: socketPath,
    socket: {
      open(socket) {
        socket.write(`${JSON.stringify({ id: REQUEST_ID, method, params })}\n`);
      },
      data(socket, chunk) {
        buffer += chunk.toString();
        const newline = buffer.indexOf("\n");
        if (newline === -1) return;
        socket.end();
        const response = JSON.parse(buffer.slice(0, newline));
        if (response.error) return reject(new Error(`${method}: ${response.error.message}`));
        resolve(response.result as T);
      },
      error(_socket, error) {
        reject(error);
      },
    },
  });
  return promise;
}

function pane(paneId: string): PaneNode {
  return { type: "pane", pane_id: paneId };
}

function split(direction: SplitDirection, ratio: number, first: LayoutNode, second: LayoutNode): SplitNode {
  return { type: "split", direction, ratio, first, second };
}

// N panes in equal slots along one direction, as a right-leaning chain of binary splits
function evenPanes(paneIds: string[], direction: SplitDirection): LayoutNode {
  const [head, ...rest] = paneIds;
  if (rest.length === 0) return pane(head);
  return split(direction, 1 / paneIds.length, pane(head), evenPanes(rest, direction));
}

const sideBySide: LayoutBuilder = (paneIds) => evenPanes(paneIds, SplitDirection.Right);
const stacked: LayoutBuilder = (paneIds) => evenPanes(paneIds, SplitDirection.Down);

// The first pane takes half the tab; the others share the other half evenly.
const mainOnTop: LayoutBuilder = ([main, ...others]) =>
  split(SplitDirection.Down, HALF, pane(main), evenPanes(others, SplitDirection.Right));
const mainOnLeft: LayoutBuilder = ([main, ...others]) =>
  split(SplitDirection.Right, HALF, pane(main), evenPanes(others, SplitDirection.Down));

// Two rows of two, filled row by row like tmux's tiled layout
const grid: LayoutBuilder = (paneIds) =>
  split(SplitDirection.Down, HALF, sideBySide(paneIds.slice(0, 2)), sideBySide(paneIds.slice(2)));

const LAYOUT_CYCLES: Record<number, LayoutBuilder[]> = {
  2: [sideBySide, stacked],
  3: [mainOnTop, mainOnLeft],
  4: [mainOnTop, mainOnLeft, grid],
};

function leaves(node: LayoutNode): string[] {
  if (node.type === "pane") return [node.pane_id];
  return [...leaves(node.first), ...leaves(node.second)];
}

// Same tree shape and split directions; pane ids and ratios are ignored.
function sameStructure(left: LayoutNode, right: LayoutNode): boolean {
  if (left.type === "pane" || right.type === "pane") return left.type === right.type;
  return (
    left.direction === right.direction &&
    sameStructure(left.first, right.first) &&
    sameStructure(left.second, right.second)
  );
}

function nextLayout(root: LayoutNode, paneIds: string[]): LayoutNode | undefined {
  const cycle = LAYOUT_CYCLES[paneIds.length];
  if (!cycle) return undefined;
  const current = cycle.findIndex((build) => sameStructure(root, build(paneIds)));
  return cycle[(current + 1) % cycle.length](paneIds);
}

// The first pane opens the scratch tab; the rest join it, so only one extra tab ever appears.
async function moveToScratchTab(paneIds: string[]): Promise<void> {
  const [first, ...rest] = paneIds;
  const moved = await request<PaneMoveResult>("pane.move", {
    pane_id: first,
    destination: { type: "new_tab" },
    focus: false,
  });
  const scratchTabId = moved.move_result.pane.tab_id;
  for (const paneId of rest) {
    await request("pane.move", {
      pane_id: paneId,
      destination: { type: "tab", tab_id: scratchTabId, target_pane_id: first, split: SplitDirection.Right },
      focus: false,
    });
  }
}

async function moveNextTo(paneId: string, targetPaneId: string, node: SplitNode): Promise<void> {
  await request("pane.move", {
    pane_id: paneId,
    destination: { type: "tab", tab_id: tabId, target_pane_id: targetPaneId, split: node.direction, ratio: node.ratio },
    focus: false,
  });
}

// Top-down: the leaf holding this subtree's first pane is split, the second subtree's first pane
// goes next to it, then each half is built inside its own leaf.
async function build(node: LayoutNode): Promise<void> {
  if (node.type === "pane") return;
  await moveNextTo(leaves(node.second)[0], leaves(node.first)[0], node);
  await build(node.first);
  await build(node.second);
}

const { layout } = await request<LayoutExportResult>("layout.export", { tab_id: tabId });
const paneIds = leaves(layout.root);
const target = nextLayout(layout.root, paneIds);
if (!target) process.exit(0);

await request("pane.zoom", { pane_id: focusedPaneId, mode: "off" });
const anchor = leaves(target)[0];
await moveToScratchTab(paneIds.filter((paneId) => paneId !== anchor));
await build(target);
await request("pane.focus", { pane_id: focusedPaneId });
