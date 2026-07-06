"use client";

import type { Status } from "@/types";

export default function StatusDropdown({
  statuses,
  value,
  onChange,
}: {
  statuses: Status[];
  value: string | null;
  onChange: (statusId: string) => void;
}) {
  const sorted = [...statuses].sort((a, b) => a.sort_order - b.sort_order);

  return (
    <select
      value={value ?? ""}
      onChange={(e) => onChange(e.target.value)}
      className="rounded border border-slate-300 bg-white px-3 py-1.5 text-sm font-medium text-slate-800 focus:border-slate-500 focus:outline-none"
    >
      <option value="" disabled>
        Select status
      </option>
      {sorted.map((s) => (
        <option key={s.id} value={s.id}>
          {s.name}
        </option>
      ))}
    </select>
  );
}
