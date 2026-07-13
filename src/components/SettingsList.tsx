"use client";

import { useState } from "react";
import { EditableText } from "./EditableField";
import {
  addSettingsItem,
  renameSettingsItem,
  deleteSettingsItem,
  reorderSettingsItems,
  updateCategoryColor,
  type SettingsTable,
} from "@/lib/data";

type Item = { id: string; name: string; sort_order: number; color?: string | null };

export default function SettingsList<T extends Item>({
  title,
  table,
  items,
  onChanged,
  sortAlphabetically = false,
  showColor = false,
  extraToggle,
}: {
  title: string;
  table: SettingsTable;
  items: T[];
  onChanged: () => void;
  sortAlphabetically?: boolean;
  showColor?: boolean;
  // Optional extra per-row checkbox, e.g. "Counts as a call attempt" on Statuses.
  extraToggle?: {
    label: string;
    getValue: (item: T) => boolean;
    onToggle: (item: T, value: boolean) => Promise<void>;
  };
}) {
  const [adding, setAdding] = useState(false);
  const [newName, setNewName] = useState("");
  const [dragIndex, setDragIndex] = useState<number | null>(null);
  const [orderOverride, setOrderOverride] = useState<T[] | null>(null);

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
      <h2 className="mb-2 text-lg font-semibold text-slate-800">{title}</h2>
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
                onChange={(e) =>
                  updateCategoryColor(item.id, e.target.value).then(onChanged)
                }
                className="h-6 w-6 shrink-0 cursor-pointer rounded border border-slate-200"
                title="Category colour"
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
              onClick={() => {
                if (confirm(`Remove "${item.name}"?`)) {
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

      {adding ? (
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
      )}
    </div>
  );
}
