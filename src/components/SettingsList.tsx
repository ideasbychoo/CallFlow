"use client";

import { useState } from "react";
import { EditableText } from "./EditableField";
import Modal from "./Modal";
import {
  addSettingsItem,
  renameSettingsItem,
  deleteSettingsItem,
  reorderSettingsItems,
  updateCategoryColor,
  updateSegmentColor,
  countStaffUsingLookup,
  reassignAndDeleteLookup,
  type SettingsTable,
} from "@/lib/data";

type Item = {
  id: string;
  name: string;
  sort_order: number;
  color?: string | null;
  is_official?: boolean;
};

export default function SettingsList<T extends Item>({
  title,
  table,
  items,
  onChanged,
  sortAlphabetically = false,
  showColor = false,
  colorField = "categories",
  disableAdd = false,
  extraToggle,
  reassignOnDelete,
}: {
  title: string;
  table: SettingsTable;
  items: T[];
  onChanged: () => void;
  sortAlphabetically?: boolean;
  showColor?: boolean;
  // Which color-storing table to write to when showColor is set -- categories
  // and segments each have their own color column/update function.
  colorField?: "categories" | "segments";
  // Hides "+ Add another" -- used for Departments/Seniority Levels, which the
  // ingest agents used to auto-create into (see reassignOnDelete below); new
  // ones should now be added deliberately from here, so this stays available,
  // just not disabled by default. Kept as an option for future lock-down.
  disableAdd?: boolean;
  // Optional extra per-row checkbox, e.g. "Counts as a call attempt" on Statuses.
  extraToggle?: {
    label: string;
    getValue: (item: T) => boolean;
    onToggle: (item: T, value: boolean) => Promise<void>;
  };
  // When set, deleting an item asks how many staff records use it and lets
  // the user reassign them to one of the "Official" items first, instead of
  // just deleting outright. Used for Departments/Seniority Levels.
  reassignOnDelete?: {
    lookupTable: "departments" | "seniority_levels";
    staffColumn: "department_id" | "seniority_id";
    noun: string; // e.g. "Department" / "Seniority Level"
  };
}) {
  const [adding, setAdding] = useState(false);
  const [newName, setNewName] = useState("");
  const [dragIndex, setDragIndex] = useState<number | null>(null);
  const [orderOverride, setOrderOverride] = useState<T[] | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<T | null>(null);
  const [deleteCount, setDeleteCount] = useState<number | null>(null);
  const [reassignTo, setReassignTo] = useState<string>("");
  const [deleting, setDeleting] = useState(false);

  const reorderable = !sortAlphabetically;

  const sorted =
    orderOverride ??
    (sortAlphabetically
      ? [...items].sort((a, b) => a.name.localeCompare(b.name))
      : [...items].sort((a, b) => a.sort_order - b.sort_order));

  async function handleAdd() {
    if (!newName.trim()) {
      setAdding(false);
      return;
    }
    const nextOrder =
      items.length > 0 ? Math.max(...items.map((i) => i.sort_order)) + 1 : 1;
    await addSettingsItem(table, newName.trim(), nextOrder);
    setNewName("");
    setAdding(false);
    onChanged();
  }

  function handleDrop(targetIndex: number) {
    if (dragIndex === null || dragIndex === targetIndex) {
      setDragIndex(null);
      return;
    }
    const reordered = [...sorted];
    const [moved] = reordered.splice(dragIndex, 1);
    reordered.splice(targetIndex, 0, moved);
    setOrderOverride(reordered); // optimistic, so the drag feels instant
    setDragIndex(null);
    reorderSettingsItems(
      table,
      reordered.map((i) => i.id)
    ).then(() => {
      onChanged();
      setOrderOverride(null);
    });
  }

  return (
    <div className="mb-8">
      <h2 className="mb-2 text-lg font-semibold text-slate-800">
        {title} ({items.length})
      </h2>
      <div className="divide-y divide-slate-100 rounded border border-slate-200 bg-white">
        {sorted.map((item, index) => (
          <div
            key={item.id}
            draggable={reorderable}
            onDragStart={() => setDragIndex(index)}
            onDragOver={(e) => reorderable && e.preventDefault()}
            onDrop={() => reorderable && handleDrop(index)}
            className={`flex items-center gap-2 px-3 py-2 ${
              reorderable ? "cursor-move" : ""
            } ${dragIndex === index ? "opacity-40" : ""}`}
          >
            {reorderable && (
              <span className="shrink-0 select-none text-slate-300" title="Drag to reorder">
                ⠿
              </span>
            )}
            {showColor && (
              <input
                type="color"
                value={item.color ?? "#94a3b8"}
                onChange={(e) => {
                  const updateFn = colorField === "segments" ? updateSegmentColor : updateCategoryColor;
                  updateFn(item.id, e.target.value).then(onChanged);
                }}
                className="h-6 w-6 shrink-0 cursor-pointer rounded border border-slate-200"
                title="Colour"
              />
            )}
            <EditableText
              value={item.name}
              onSave={(v) => renameSettingsItem(table, item.id, v).then(onChanged)}
              className="flex-1 rounded border border-transparent bg-transparent text-sm text-slate-800 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
            />
            {extraToggle && (
              <label className="flex shrink-0 items-center gap-1.5 text-xs text-slate-500">
                <input
                  type="checkbox"
                  checked={extraToggle.getValue(item)}
                  onChange={(e) => extraToggle.onToggle(item, e.target.checked).then(onChanged)}
                  className="rounded border-slate-300"
                />
                {extraToggle.label}
              </label>
            )}
            <button
              onClick={async () => {
                if (reassignOnDelete) {
                  const count = await countStaffUsingLookup(reassignOnDelete.staffColumn, item.id);
                  setDeleteCount(count);
                  setDeleteTarget(item);
                  setReassignTo("");
                } else if (confirm(`Remove "${item.name}"?`)) {
                  deleteSettingsItem(table, item.id).then(onChanged);
                }
              }}
              className="text-xs text-slate-300 hover:text-red-500"
            >
              ✕
            </button>
          </div>
        ))}
        {sorted.length === 0 && (
          <p className="px-3 py-2 text-sm text-slate-400">Nothing here yet.</p>
        )}
      </div>

      {!disableAdd &&
        (adding ? (
          <div className="mt-2 flex items-center gap-2">
            <input
              autoFocus
              value={newName}
              onChange={(e) => setNewName(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && handleAdd()}
              onBlur={handleAdd}
              className="rounded border border-slate-300 px-2 py-1 text-sm text-slate-800 focus:border-slate-500 focus:outline-none"
              placeholder="Name"
            />
          </div>
        ) : (
          <button
            onClick={() => setAdding(true)}
            className="mt-2 text-sm text-slate-500 hover:text-slate-800"
          >
            + Add another
          </button>
        ))}

      {reassignOnDelete && deleteTarget && (
        <Modal onClose={() => setDeleteTarget(null)}>
          <div className="w-full max-w-md p-6">
            <h3 className="mb-2 text-lg font-semibold text-slate-800">
              Delete &ldquo;{deleteTarget.name}&rdquo;?
            </h3>
            {deleteCount === null ? (
              <p className="text-sm text-slate-500">Checking how many staff records use this…</p>
            ) : deleteCount === 0 ? (
              <p className="text-sm text-slate-600">
                No staff records are assigned to this {reassignOnDelete.noun}. It&rsquo;s safe to delete.
              </p>
            ) : (
              <>
                <p className="text-sm text-slate-600">
                  There {deleteCount === 1 ? "is" : "are"} <strong>{deleteCount}</strong> staff record
                  {deleteCount === 1 ? "" : "s"} assigned to this {reassignOnDelete.noun}. Which{" "}
                  {reassignOnDelete.noun} would you like to assign these records to instead?
                </p>
                <select
                  value={reassignTo}
                  onChange={(e) => setReassignTo(e.target.value)}
                  className="mt-3 w-full rounded border border-slate-300 px-3 py-2 text-sm text-slate-800 focus:border-slate-500 focus:outline-none"
                >
                  <option value="">Leave unassigned</option>
                  {items
                    .filter((i) => i.is_official && i.id !== deleteTarget.id)
                    .sort((a, b) => a.name.localeCompare(b.name))
                    .map((i) => (
                      <option key={i.id} value={i.id}>
                        {i.name}
                      </option>
                    ))}
                </select>
                {items.filter((i) => i.is_official && i.id !== deleteTarget.id).length === 0 && (
                  <p className="mt-1 text-xs text-amber-600">
                    No other item is marked &ldquo;Official&rdquo; yet -- records will be left unassigned.
                  </p>
                )}
              </>
            )}
            <div className="mt-4 flex justify-end gap-2">
              <button
                onClick={() => setDeleteTarget(null)}
                className="rounded border border-slate-300 px-3 py-1.5 text-sm text-slate-600 hover:bg-slate-50"
              >
                Cancel
              </button>
              <button
                disabled={deleteCount === null || deleting}
                onClick={async () => {
                  setDeleting(true);
                  try {
                    await reassignAndDeleteLookup(
                      reassignOnDelete.lookupTable,
                      reassignOnDelete.staffColumn,
                      deleteTarget.id,
                      reassignTo || null
                    );
                    setDeleteTarget(null);
                    onChanged();
                  } catch (err) {
                    console.error(err);
                    alert("Couldn't delete. Please try again.");
                  } finally {
                    setDeleting(false);
                  }
                }}
                className="rounded bg-red-600 px-3 py-1.5 text-sm font-medium text-white hover:bg-red-500 disabled:opacity-50"
              >
                {deleting ? "Confirming\u2026" : "Confirm"}
              </button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
}
