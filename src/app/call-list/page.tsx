"use client";

import { useEffect, useMemo, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import OrganisationCard from "@/components/OrganisationCard";
import MultiSelectFilter from "@/components/MultiSelectFilter";
import {
  fetchOrganisations,
  fetchSettingsLists,
  createOrganisation,
} from "@/lib/data";
import type {
  Organisation,
  Status,
  Department,
  SeniorityLevel,
  Category,
  SortField,
  SortDirection,
} from "@/types";

function CallListInner() {
  const searchParams = useSearchParams();
  const statusFilter = searchParams.get("status");

  const [orgs, setOrgs] = useState<Organisation[]>([]);
  const [statuses, setStatuses] = useState<Status[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [seniorityLevels, setSeniorityLevels] = useState<SeniorityLevel[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);

  const [search, setSearch] = useState("");
  const [categoryFilter, setCategoryFilter] = useState<string[]>([]);
  const [countryFilter, setCountryFilter] = useState<string[]>([]);
  const [staffMin, setStaffMin] = useState<string>("1");
  const [staffMax, setStaffMax] = useState<string>("");
  const [sortField, setSortField] = useState<SortField>("date_spotted");
  const [sortDirection, setSortDirection] = useState<SortDirection>("desc");

  async function load() {
    const [orgData, settings] = await Promise.all([
      fetchOrganisations(),
      fetchSettingsLists(),
    ]);
    setOrgs(orgData);
    setStatuses(settings.statuses);
    setDepartments(settings.departments);
    setSeniorityLevels(settings.seniorityLevels);
    setCategories(settings.categories);
    setLoading(false);
  }

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const countryOptions = useMemo(() => {
    const set = new Set<string>();
    orgs.forEach((o) => o.country && set.add(o.country));
    return Array.from(set).sort();
  }, [orgs]);

  const sortedCategoryOptions = useMemo(
    () =>
      [...categories]
        .sort((a, b) => a.name.localeCompare(b.name))
        .map((c) => ({ value: c.id, label: c.name })),
    [categories]
  );

  const filtered = useMemo(() => {
    let result = orgs;

    if (statusFilter) {
      result = result.filter((o) => o.status_id === statusFilter);
    }
    if (categoryFilter.length > 0) {
      result = result.filter(
        (o) => o.category_id && categoryFilter.includes(o.category_id)
      );
    }
    if (countryFilter.length > 0) {
      result = result.filter((o) => o.country && countryFilter.includes(o.country));
    }
    const min = staffMin.trim() ? parseInt(staffMin, 10) : null;
    const max = staffMax.trim() ? parseInt(staffMax, 10) : null;
    if (min !== null || max !== null) {
      result = result.filter((o) => {
        const count = (o.staff ?? []).length;
        if (min !== null && count < min) return false;
        if (max !== null && count > max) return false;
        return true;
      });
    }
    if (search.trim()) {
      const q = search.trim().toLowerCase();
      result = result.filter((o) => {
        if (o.name.toLowerCase().includes(q)) return true;
        if (o.notes?.toLowerCase().includes(q)) return true;
        if (o.angle?.toLowerCase().includes(q)) return true;
        if ((o.staff ?? []).some((p) => p.full_name.toLowerCase().includes(q)))
          return true;
        return false;
      });
    }

    const sorted = [...result].sort((a, b) => {
      let cmp = 0;
      if (sortField === "name") {
        cmp = a.name.localeCompare(b.name);
      } else if (sortField === "date_spotted") {
        cmp =
          new Date(a.date_spotted).getTime() -
          new Date(b.date_spotted).getTime();
      } else if (sortField === "last_interaction_at") {
        cmp =
          new Date(a.last_interaction_at ?? 0).getTime() -
          new Date(b.last_interaction_at ?? 0).getTime();
      }
      return sortDirection === "asc" ? cmp : -cmp;
    });

    return sorted;
  }, [orgs, statusFilter, categoryFilter, countryFilter, staffMin, staffMax, search, sortField, sortDirection]);

  async function handleAddOrganisation() {
    const defaultStatus = statuses.find((s) => s.sort_order === 1);
    await createOrganisation({
      name: "New organisation",
      status_id: defaultStatus?.id ?? null,
    });
    load();
  }

  const activeStatusName = statusFilter
    ? statuses.find((s) => s.id === statusFilter)?.name
    : null;

  return (
    <div className="mx-auto max-w-6xl px-8 pb-8">
      <div className="sticky top-0 z-10 -mx-8 bg-slate-50 px-8 pb-4 pt-8">
        <div className="mb-6 flex items-center justify-between">
          <h1 className="text-3xl font-semibold text-slate-800">
            Call List{activeStatusName ? ` · ${activeStatusName}` : ""}
          </h1>
          <button
            onClick={handleAddOrganisation}
            className="rounded bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700"
          >
            + Add organisation
          </button>
        </div>

        <div className="mb-4 flex flex-wrap items-center gap-3">
          <input
            type="text"
            placeholder="Search: find an org, person or note"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="flex-1 min-w-[240px] rounded border border-slate-300 px-3 py-2 text-sm text-slate-800 focus:border-slate-500 focus:outline-none"
          />
          <select
            value={`${sortField}:${sortDirection}`}
            onChange={(e) => {
              const [field, dir] = e.target.value.split(":");
              setSortField(field as SortField);
              setSortDirection(dir as SortDirection);
            }}
            className="rounded border border-slate-300 px-3 py-2 text-sm text-slate-800 focus:border-slate-500 focus:outline-none"
          >
            <option value="date_spotted:desc">Date spotted (newest)</option>
            <option value="date_spotted:asc">Date spotted (oldest)</option>
            <option value="last_interaction_at:desc">
              Most recent interaction (newest)
            </option>
            <option value="last_interaction_at:asc">
              Most recent interaction (oldest)
            </option>
            <option value="name:asc">Organisation name (A–Z)</option>
            <option value="name:desc">Organisation name (Z–A)</option>
          </select>
        </div>

        <div className="flex flex-wrap items-center gap-3">
          <span className="text-sm text-slate-500">Filters:</span>
          <MultiSelectFilter
            label="Category"
            options={sortedCategoryOptions}
            selected={categoryFilter}
            onChange={setCategoryFilter}
          />
          <MultiSelectFilter
            label="Country"
            options={countryOptions.map((c) => ({ value: c, label: c }))}
            selected={countryFilter}
            onChange={setCountryFilter}
          />
          <div className="flex items-center gap-1.5 rounded border border-slate-300 bg-white px-3 py-1.5 text-sm text-slate-700">
            <span>Staff identified:</span>
            <input
              type="number"
              min={0}
              value={staffMin}
              onChange={(e) => setStaffMin(e.target.value)}
              placeholder="from"
              className="w-14 rounded border border-slate-200 px-1 py-0.5 text-slate-800 focus:border-slate-400 focus:outline-none"
            />
            <span className="text-slate-400">–</span>
            <input
              type="number"
              min={0}
              value={staffMax}
              onChange={(e) => setStaffMax(e.target.value)}
              placeholder="to"
              className="w-14 rounded border border-slate-200 px-1 py-0.5 text-slate-800 focus:border-slate-400 focus:outline-none"
            />
          </div>
        </div>
      </div>

      {loading ? (
        <p className="text-sm text-slate-400">Loading…</p>
      ) : filtered.length === 0 ? (
        <p className="text-sm text-slate-400">No organisations match.</p>
      ) : (
        filtered.map((org) => (
          <OrganisationCard
            key={org.id}
            org={org}
            statuses={statuses}
            departments={departments}
            seniorityLevels={seniorityLevels}
            categories={categories}
            onChanged={load}
          />
        ))
      )}
    </div>
  );
}

export default function CallListPage() {
  return (
    <Suspense fallback={<div className="p-8 text-sm text-slate-400">Loading…</div>}>
      <CallListInner />
    </Suspense>
  );
}
