"use client";

import { useState, useEffect } from "react";

function todayPrefix(): string {
  const today = new Date();
  const formatted = today.toLocaleDateString("en-GB", {
    day: "numeric",
    month: "short",
    year: "numeric",
  });
  return `${formatted}: `;
}

export function EditableText({
  value,
  onSave,
  placeholder,
  className,
  multiline = false,
  autoDatePrefix = false,
}: {
  value: string | null | undefined;
  onSave: (value: string) => void;
  placeholder?: string;
  className?: string;
  multiline?: boolean;
  // When true, focusing this field while it's still empty (i.e. you're
  // creating a brand new note rather than editing an existing one) prefixes
  // the draft with today's date, so you don't have to type it out yourself.
  autoDatePrefix?: boolean;
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

  function handleFocus() {
    if (autoDatePrefix && draft === "") {
      setDraft(todayPrefix());
    }
  }

  const baseClass =
    className ??
    "w-full rounded border border-transparent bg-transparent px-1 py-0.5 text-sm text-slate-800 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none";

  if (multiline) {
    return (
      <textarea
        value={draft}
        onChange={(e) => setDraft(e.target.value)}
        onFocus={handleFocus}
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
      onFocus={handleFocus}
      onBlur={save}
      placeholder={placeholder}
      className={baseClass}
    />
  );
}
