"use client";

import { useEffect, useRef, useState } from "react";
import {
  fetchAllEmailTemplates,
  createEmailTemplate,
  updateEmailTemplate,
  deleteEmailTemplate,
  MAIL_MERGE_TAGS,
} from "@/lib/data";
import type { EmailTemplate } from "@/types";

function TemplateEditor({
  template,
  onChanged,
  onDelete,
}: {
  template: EmailTemplate;
  onChanged: () => void;
  onDelete: () => void;
}) {
  const [title, setTitle] = useState(template.title);
  const [subject, setSubject] = useState(template.subject);
  const [body, setBody] = useState(template.body);
  const [saving, setSaving] = useState(false);
  const bodyRef = useRef<HTMLTextAreaElement>(null);

  async function save(fields: Partial<EmailTemplate>) {
    setSaving(true);
    try {
      await updateEmailTemplate(template.id, fields);
      onChanged();
    } finally {
      setSaving(false);
    }
  }

  function insertTag(tag: string) {
    const el = bodyRef.current;
    if (!el) {
      setBody((b) => b + tag);
      return;
    }
    const start = el.selectionStart ?? body.length;
    const end = el.selectionEnd ?? body.length;
    const next = body.slice(0, start) + tag + body.slice(end);
    setBody(next);
    save({ body: next });
    requestAnimationFrame(() => {
      el.focus();
      el.selectionStart = el.selectionEnd = start + tag.length;
    });
  }

  return (
    <div className="rounded-lg border border-slate-200 bg-white p-4">
      <div className="mb-3 flex items-center justify-between gap-3">
        <input
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          onBlur={() => save({ title })}
          className="w-full rounded border border-transparent px-2 py-1 text-lg font-medium text-slate-800 hover:border-slate-200 focus:border-slate-400 focus:outline-none"
        />
        <button
          onClick={() => {
            if (confirm(`Delete "${template.title}"?`)) onDelete();
          }}
          className="shrink-0 text-sm text-slate-300 hover:text-red-500"
        >
          Delete
        </button>
      </div>

      <label className="mb-1 block text-xs font-medium text-slate-500">Subject line</label>
      <input
        value={subject}
        onChange={(e) => setSubject(e.target.value)}
        onBlur={() => save({ subject })}
        className="mb-3 w-full rounded border border-slate-200 px-2 py-1.5 text-sm text-slate-800 focus:border-slate-400 focus:outline-none"
      />

      <label className="mb-1 block text-xs font-medium text-slate-500">Body copy</label>
      <textarea
        ref={bodyRef}
        value={body}
        onChange={(e) => setBody(e.target.value)}
        onBlur={() => save({ body })}
        rows={8}
        className="mb-2 w-full rounded border border-slate-200 px-2 py-1.5 text-sm text-slate-800 focus:border-slate-400 focus:outline-none"
      />

      <div className="flex flex-wrap gap-1.5">
        <span className="mr-1 text-xs text-slate-400">Insert:</span>
        {MAIL_MERGE_TAGS.map((t) => (
          <button
            key={t.tag}
            onClick={() => insertTag(t.tag)}
            title={t.label}
            className="rounded border border-slate-200 bg-slate-50 px-2 py-0.5 text-[11px] text-slate-600 hover:bg-slate-100"
          >
            {t.label}
          </button>
        ))}
      </div>
      {saving && <p className="mt-2 text-xs text-slate-400">Saving…</p>}
    </div>
  );
}

export default function EmailTemplatesPage() {
  const [templates, setTemplates] = useState<EmailTemplate[]>([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    const data = await fetchAllEmailTemplates();
    setTemplates(data);
    setLoading(false);
  }

  useEffect(() => {
    load();
  }, []);

  async function handleAdd() {
    try {
      await createEmailTemplate({
        title: "New template",
        subject: "",
        body: "Hi {{staff.first_name}},\n\n",
      });
      load();
    } catch (err) {
      console.error(err);
      alert("Couldn't add the new template. Please try again.");
    }
  }

  return (
    <div className="px-8 pb-8">
      <div className="sticky top-0 z-10 -mx-8 bg-slate-50 px-8 pb-4 pt-8">
        <div className="mb-4 flex items-center justify-between">
          <h1 className="text-3xl font-semibold text-slate-800">Email Templates</h1>
          <button
            onClick={handleAdd}
            className="rounded bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700"
          >
            + Add template
          </button>
        </div>
        <p className="text-sm text-slate-500">
          Insert mail merge tags into the body copy — they&rsquo;ll be replaced with the
          organisation&rsquo;s and contact&rsquo;s details when you send.
        </p>
      </div>

      {loading ? (
        <p className="text-sm text-slate-400">Loading…</p>
      ) : templates.length === 0 ? (
        <p className="text-sm text-slate-400">No templates yet — add one to get started.</p>
      ) : (
        <div className="space-y-4">
          {templates.map((t) => (
            <TemplateEditor
              key={t.id}
              template={t}
              onChanged={load}
              onDelete={() => deleteEmailTemplate(t.id).then(load)}
            />
          ))}
        </div>
      )}
    </div>
  );
}
