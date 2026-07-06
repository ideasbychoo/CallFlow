"use client";

import { useState } from "react";
import { EditableText } from "./EditableField";
import {
  addSettingsItem,
  renameSettingsItem,
  deleteSettingsItem,
  updateCategoryColor,
  type SettingsTable,
} from "@/lib/data";

type Item = { id: string; name: string; sort_order: number; color?: string | null };

export default function SettingsList({
  title,
  table,
  items,
  onChanged,
  sortAlphabetically = false,
  showColor = false,
}: {
  title: string;
  table: SettingsTable;
  items: Item[];
  onChanged: () => void;
  sortAlphabetically?: boolean;
  showColor?: boolean;
}) {
  const [adding, setAdding] = useState(false);
  const [newName, setNewName] = useState("");

  const sorted = sortAlphabetically
    ? [...items].sort((a, b) => a.name.localeCompare(b.name))
    : [...items].sort((a, b) => a.sort_order - b.sort_order);

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

  return (
    <div className="mb-8">
      <h2 className="mb-2 text-lg font-semibold text-slate-800">{title}</h2>
      <div className="divide-y divide-slate-100 rounded border border-slate-200 bg-white">
        {sorted.map((item) => (
          <div key={item.id} className="flex items-center gap-2 px-3 py-2">
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
