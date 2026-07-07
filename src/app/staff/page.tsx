"use client";

import { useEffect, useMemo, useState } from "react";
import { EditableText } from "@/components/EditableField";
import {
  fetchAllStaff,
  fetchAllOrganisationsBasic,
  fetchSettingsLists,
  updateStaffMember,
  upsertStaffMember,
  deleteStaffMember,
} from "@/lib/data";
import type { Department, SeniorityLevel, StaffMember } from "@/types";

type Row = StaffMember & { organisation?: { id: string; name: string } | null };

export default function StaffPage() {
  const [rows, setRows] = useState<Row[]>([]);
  const [orgOptions, setOrgOptions] = useState<{ id: string; name: string }[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [seniorityLevels, setSeniorityLevels] = useState<SeniorityLevel[]>([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);

  async function load() {
    const [staffData, orgs, settings] = await Promise.all([
      fetchAllStaff(),
      fetchAllOrganisationsBasic(),
      fetchSettingsLists(),
    ]);
    setRows(staffData);
    setOrgOptions(orgs);
    setDepartments(settings.departments);
    setSeniorityLevels(settings.seniorityLevels);
    setLoading(false);
  }

  useEffect(() => {
    load();
  }, []);

  const sortedDepartments = useMemo(
    () => [...departments].sort((a, b) => a.sort_order - b.sort_order),
    [departments]
  );
  const sortedSeniority = useMemo(
    () => [...seniorityLevels].sort((a, b) => a.sort_order - b.sort_order),
    [seniorityLevels]
  );

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    const list = q
      ? rows.filter(
          (r) =>
            r.full_name.toLowerCase().includes(q) ||
            r.organisation?.name.toLowerCase().includes(q) ||
            r.job_title?.toLowerCase().includes(q)
        )
      : rows;
    return [...list].sort((a, b) => a.full_name.localeCompare(b.full_name));
  }, [rows, search]);

  async function save(id: string, fields: Record<string, unknown>) {
    await updateStaffMember(id, fields);
    load();
  }

  async function handleAdd() {
    if (orgOptions.length === 0) return;
    await upsertStaffMember({
      organisation_id: orgOptions[0].id,
      full_name: "New person",
    });
    load();
  }

  const cellClass =
    "rounded border border-transparent bg-transparent px-1 py-0.5 text-xs text-slate-800 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none";

  return (
    <div className="px-8 pb-8">
      <div className="sticky top-0 z-10 -mx-8 bg-slate-50 px-8 pb-4 pt-8">
        <div className="mb-4 flex items-center justify-between">
          <h1 className="text-3xl font-semibold text-slate-800">Staff</h1>
          <button
            onClick={handleAdd}
            className="rounded bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700"
          >
            + Add person
          </button>
        </div>
        <input
          type="text"
          placeholder="Search people, organisations, job titles…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-80 rounded border border-slate-300 px-3 py-2 text-sm text-slate-800 focus:border-slate-500 focus:outline-none"
        />
        {!loading && <p className="mt-2 text-sm text-slate-500">{filtered.length} people</p>}
      </div>

      {loading ? (
        <p className="text-sm text-slate-400">Loading…</p>
      ) : (
        <div className="overflow-x-auto rounded-lg border border-slate-200 bg-white">
          <table className="w-full min-w-[2000px] border-collapse text-xs">
            <thead className="sticky top-0 z-[5] bg-slate-100 text-left text-slate-600">
              <tr>
                {[
                  "Organisation", "Full name", "Job title", "Department", "Seniority",
                  "Email", "Direct dial", "LinkedIn", "Background notes",
                  "Availability notes", "Conversation notes", "",
                ].map((h) => (
                  <th key={h} className="whitespace-nowrap border-b border-slate-200 px-2 py-2 font-medium">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((person) => (
                <tr key={person.id} className="border-b border-slate-100 align-top hover:bg-slate-50">
                  <td className="min-w-[200px] px-2 py-1">
                    <select
                      value={person.organisation_id}
                      onChange={(e) => save(person.id, { organisation_id: e.target.value })}
                      className={cellClass}
                    >
                      {orgOptions.map((o) => (
                        <option key={o.id} value={o.id}>{o.name}</option>
                      ))}
                    </select>
                  </td>
                  <td className="min-w-[160px] px-2 py-1">
                    <EditableText value={person.full_name} onSave={(v) => save(person.id, { full_name: v })} className={cellClass + " font-medium"} />
                  </td>
                  <td className="min-w-[180px] px-2 py-1">
                    <EditableText value={person.job_title} onSave={(v) => save(person.id, { job_title: v })} className={cellClass} />
                  </td>
                  <td className="min-w-[150px] px-2 py-1">
                    <select
                      value={person.department_id ?? ""}
                      onChange={(e) => save(person.id, { department_id: e.target.value || null })}
                      className={cellClass}
                    >
                      <option value="">—</option>
                      {sortedDepartments.map((d) => (
                        <option key={d.id} value={d.id}>{d.name}</option>
                      ))}
                    </select>
                  </td>
                  <td className="min-w-[130px] px-2 py-1">
                    <select
                      value={person.seniority_id ?? ""}
                      onChange={(e) => save(person.id, { seniority_id: e.target.value || null })}
                      className={cellClass}
                    >
                      <option value="">—</option>
                      {sortedSeniority.map((s) => (
                        <option key={s.id} value={s.id}>{s.name}</option>
                      ))}
                    </select>
                  </td>
                  <td className="min-w-[180px] px-2 py-1">
                    <EditableText value={person.email} onSave={(v) => save(person.id, { email: v })} className={cellClass} />
                  </td>
                  <td className="min-w-[140px] px-2 py-1">
                    <EditableText value={person.direct_dial} onSave={(v) => save(person.id, { direct_dial: v })} className={cellClass} />
                  </td>
                  <td className="min-w-[180px] px-2 py-1">
                    <EditableText value={person.linkedin} onSave={(v) => save(person.id, { linkedin: v })} className={cellClass} />
                  </td>
                  <td className="min-w-[220px] px-2 py-1">
                    <EditableText value={person.background_notes} onSave={(v) => save(person.id, { background_notes: v })} multiline className={cellClass} />
                  </td>
                  <td className="min-w-[180px] px-2 py-1">
                    <EditableText value={person.availability_notes} onSave={(v) => save(person.id, { availability_notes: v })} multiline className={cellClass} />
                  </td>
                  <td className="min-w-[220px] px-2 py-1">
                    <EditableText value={person.conversation_notes} onSave={(v) => save(person.id, { conversation_notes: v })} multiline className={cellClass} />
                  </td>
                  <td className="px-2 py-1">
                    <button
                      onClick={() => {
                        if (confirm(`Remove ${person.full_name}?`)) deleteStaffMember(person.id).then(load);
                      }}
                      className="text-slate-300 hover:text-red-500"
                    >
                      ✕
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
