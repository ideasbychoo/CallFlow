"use client";

import { useState, useEffect } from "react";

export function EditableText({
  value,
  onSave,
  placeholder,
  className,
  multiline = false,
}: {
  value: string | null | undefined;
  onSave: (value: string) => void;
  placeholder?: string;
  className?: string;
  multiline?: boolean;
}) {
  const [draft, setDraft] = useState(value ?? "");

  useEffect(() => {
    setDraft(value ?? "");
  }, [value]);

  function save() {
    if (draft !== (value ?? "")) {
      onSave(draft);
    }
  }

  const baseClass =
    className ??
    "w-full rounded border border-transparent bg-transparent px-1 py-0.5 text-sm hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none";

  if (multiline) {
    return (
      <textarea
        value={draft}
        onChange={(e) => setDraft(e.target.value)}
        onBlur={save}
        placeholder={placeholder}
        rows={2}
        className={baseClass + " resize-none"}
      />
    );
  }

  return (
    <input
      type="text"
      value={draft}
      onChange={(e) => setDraft(e.target.value)}
      onBlur={save}
      placeholder={placeholder}
      className={baseClass}
    />
  );
}
