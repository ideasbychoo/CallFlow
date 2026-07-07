"use client";

import { useEffect, useMemo, useState } from "react";
import { format } from "date-fns";
import { EditableText } from "@/components/EditableField";
import {
  fetchOrganisations,
  fetchSettingsLists,
  updateOrganisation,
  createOrganisation,
  deleteOrganisation,
} from "@/lib/data";
import type { Organisation, Status, Category, Country } from "@/types";

export default function OrganisationsPage() {
  const [orgs, setOrgs] = useState<Organisation[]>([]);
  const [statuses, setStatuses] = useState<Status[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [countries, setCountries] = useState<Country[]>([]);
  const [search, setSearch] = useState("");
  const [loading, setLoading] = useState(true);

  async function load() {
    const [orgData, settings] = await Promise.all([
      fetchOrganisations(),
      fetchSettingsLists(),
    ]);
    setOrgs(orgData);
    setStatuses(settings.statuses);
    setCategories(settings.categories);
    setCountries(settings.countries);
    setLoading(false);
  }

  useEffect(() => {
    load();
  }, []);

  const sortedCategories = useMemo(
    () => [...categories].sort((a, b) => a.name.localeCompare(b.name)),
    [categories]
  );
  const sortedCountries = useMemo(
    () => [...countries].sort((a, b) => a.name.localeCompare(b.name)),
    [countries]
  );
  const sortedStatuses = useMemo(
    () => [...statuses].sort((a, b) => a.sort_order - b.sort_order),
    [statuses]
  );

  const filtered = useMemo(() => {
    const q = search.trim().toLowerCase();
    const list = q
      ? orgs.filter(
          (o) =>
            o.name.toLowerCase().includes(q) ||
            o.notes?.toLowerCase().includes(q) ||
            o.angle?.toLowerCase().includes(q)
        )
      : orgs;
    return [...list].sort((a, b) => a.name.localeCompare(b.name));
  }, [orgs, search]);

  async function save(id: string, fields: Partial<Organisation>) {
    await updateOrganisation(id, fields);
    load();
  }

  async function handleAdd() {
    const defaultStatus = statuses.find((s) => s.sort_order === 1);
    await createOrganisation({ name: "New organisation", status_id: defaultStatus?.id ?? null });
    load();
  }

  const cellClass =
    "rounded border border-transparent bg-transparent px-1 py-0.5 text-xs text-slate-800 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none";

  return (
    <div className="px-8 pb-8">
      <div className="sticky top-0 z-10 -mx-8 bg-slate-50 px-8 pb-4 pt-8">
        <div className="mb-4 flex items-center justify-between">
          <h1 className="text-3xl font-semibold text-slate-800">Organisations</h1>
          <button
            onClick={handleAdd}
            className="rounded bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700"
          >
            + Add organisation
          </button>
        </div>
        <input
          type="text"
          placeholder="Search organisations…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-80 rounded border border-slate-300 px-3 py-2 text-sm text-slate-800 focus:border-slate-500 focus:outline-none"
        />
        {!loading && (
          <p className="mt-2 text-sm text-slate-500">{filtered.length} organisations</p>
        )}
      </div>

      {loading ? (
        <p className="text-sm text-slate-400">Loading…</p>
      ) : (
        <div className="overflow-x-auto rounded-lg border border-slate-200 bg-white">
          <table className="w-full min-w-[2200px] border-collapse text-xs">
            <thead className="sticky top-0 z-[5] bg-slate-100 text-left text-slate-600">
              <tr>
                {[
                  "Name", "Category", "Country", "Similar to", "Angle", "Status",
                  "Date spotted", "Website", "Team page", "Annual report", "Impact report",
                  "Org LinkedIn", "Beneficiaries", "Workers", "Notes",
                  "Staff", "Call attempts", "Recent interaction", "",
                ].map((h) => (
                  <th key={h} className="whitespace-nowrap border-b border-slate-200 px-2 py-2 font-medium">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((org) => (
                <tr key={org.id} className="border-b border-slate-100 align-top hover:bg-slate-50">
                  <td className="min-w-[180px] px-2 py-1">
                    <EditableText value={org.name} onSave={(v) => save(org.id, { name: v })} className={cellClass + " font-medium"} />
                  </td>
                  <td className="min-w-[160px] px-2 py-1">
                    <select
                      value={org.category_id ?? ""}
                      onChange={(e) => save(org.id, { category_id: e.target.value || null })}
                      className={cellClass}
                    >
                      <option value="">—</option>
                      {sortedCategories.map((c) => (
                        <option key={c.id} value={c.id}>{c.name}</option>
                      ))}
                    </select>
                  </td>
                  <td className="min-w-[130px] px-2 py-1">
                    <select
                      value={org.country ?? ""}
                      onChange={(e) => save(org.id, { country: e.target.value || null })}
                      className={cellClass}
                    >
                      <option value="">—</option>
                      {sortedCountries.map((c) => (
                        <option key={c.id} value={c.name}>{c.name}</option>
                      ))}
                    </select>
                  </td>
                  <td className="min-w-[140px] px-2 py-1">
                    <EditableText value={org.similar_to_client} onSave={(v) => save(org.id, { similar_to_client: v })} className={cellClass} />
                  </td>
                  <td className="min-w-[280px] px-2 py-1">
                    <EditableText value={org.angle} onSave={(v) => save(org.id, { angle: v })} multiline className={cellClass} />
                  </td>
                  <td className="min-w-[160px] px-2 py-1">
                    <select
                      value={org.status_id ?? ""}
                      onChange={(e) => save(org.id, { status_id: e.target.value || null })}
                      className={cellClass}
                    >
                      <option value="" disabled>—</option>
                      {sortedStatuses.map((s) => (
                        <option key={s.id} value={s.id}>{s.name}</option>
                      ))}
                    </select>
                  </td>
                  <td className="min-w-[110px] px-2 py-1">
                    <input
                      type="date"
                      value={org.date_spotted ?? ""}
                      onChange={(e) => save(org.id, { date_spotted: e.target.value })}
                      className={cellClass}
                    />
                  </td>
                  <td className="min-w-[160px] px-2 py-1">
                    <EditableText value={org.website} onSave={(v) => save(org.id, { website: v })} className={cellClass} />
                  </td>
                  <td className="min-w-[160px] px-2 py-1">
                    <EditableText value={org.team_page} onSave={(v) => save(org.id, { team_page: v })} className={cellClass} />
                  </td>
                  <td className="min-w-[160px] px-2 py-1">
                    <EditableText value={org.annual_report} onSave={(v) => save(org.id, { annual_report: v })} className={cellClass} />
                  </td>
                  <td className="min-w-[160px] px-2 py-1">
                    <EditableText value={org.impact_report} onSave={(v) => save(org.id, { impact_report: v })} className={cellClass} />
                  </td>
                  <td className="min-w-[160px] px-2 py-1">
                    <EditableText value={org.linkedin} onSave={(v) => save(org.id, { linkedin: v })} className={cellClass} />
                  </td>
                  <td className="min-w-[90px] px-2 py-1">
                    <EditableText
                      value={org.beneficiaries?.toString() ?? ""}
                      onSave={(v) => save(org.id, { beneficiaries: v.trim() ? Number(v) : null })}
                      className={cellClass}
                    />
                  </td>
                  <td className="min-w-[90px] px-2 py-1">
                    <EditableText
                      value={org.workers?.toString() ?? ""}
                      onSave={(v) => save(org.id, { workers: v.trim() ? Number(v) : null })}
                      className={cellClass}
                    />
                  </td>
                  <td className="min-w-[220px] px-2 py-1">
                    <EditableText value={org.notes} onSave={(v) => save(org.id, { notes: v })} multiline className={cellClass} />
                  </td>
                  <td className="px-2 py-1 text-center text-slate-500">{(org.staff ?? []).length}</td>
                  <td className="px-2 py-1 text-center text-slate-500">{org.call_attempts}</td>
                  <td className="whitespace-nowrap px-2 py-1 text-slate-500">
                    {org.last_interaction_at ? format(new Date(org.last_interaction_at), "d MMM yyyy") : "—"}
                  </td>
                  <td className="px-2 py-1">
                    <button
                      onClick={() => {
                        if (confirm(`Delete ${org.name}?`)) deleteOrganisation(org.id).then(load);
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
