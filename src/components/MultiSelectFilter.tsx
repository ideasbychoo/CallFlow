"use client";

import { useEffect, useRef, useState } from "react";

export default function MultiSelectFilter({
  label,
  options,
  selected,
  onChange,
}: {
  label: string;
  options: { value: string; label: string }[];
  selected: string[];
  onChange: (values: string[]) => void;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function handleClick(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) {
        setOpen(false);
      }
    }
    document.addEventListener("mousedown", handleClick);
    return () => document.removeEventListener("mousedown", handleClick);
  }, []);

  function toggle(value: string) {
    if (selected.includes(value)) {
      onChange(selected.filter((v) => v !== value));
    } else {
      onChange([...selected, value]);
    }
  }

  return (
    <div ref={ref} className="relative">
      <button
        onClick={() => setOpen((v) => !v)}
        className="rounded border border-slate-300 bg-white px-3 py-1.5 text-sm text-slate-700 hover:border-slate-400"
      >
        {label}
        {selected.length > 0 ? ` (${selected.length})` : ""} ▾
      </button>
      {open && (
        <div className="absolute z-20 mt-1 max-h-64 w-56 overflow-y-auto rounded border border-slate-200 bg-white p-2 shadow-lg">
          {options.length === 0 && (
            <p className="p-1 text-xs text-slate-400">No options yet</p>
          )}
          {options.map((opt) => (
            <label
              key={opt.value}
              className="flex cursor-pointer items-center gap-2 rounded px-1 py-1 text-sm text-slate-700 hover:bg-slate-50"
            >
              <input
                type="checkbox"
                checked={selected.includes(opt.value)}
                onChange={() => toggle(opt.value)}
              />
              {opt.label}
            </label>
          ))}
          {selected.length > 0 && (
            <button
              onClick={() => onChange([])}
              className="mt-1 w-full rounded px-1 py-1 text-left text-xs text-slate-400 hover:text-slate-700"
            >
              Clear
            </button>
          )}
        </div>
      )}
    </div>
  );
}
