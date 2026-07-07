"use client";

import { useEffect, useMemo, useState } from "react";
import {
  DndContext,
  useDraggable,
  useDroppable,
  type DragEndEvent,
} from "@dnd-kit/core";
import Link from "next/link";
import MultiSelectFilter from "@/components/MultiSelectFilter";
import CountryFlag from "@/components/CountryFlag";
import { fetchOrganisations, fetchSettingsLists, updateOrganisation } from "@/lib/data";
import type { Organisation, Status, Category, Country } from "@/types";

export default function PipelinePage() {
  const [orgs, setOrgs] = useState<Organisation[]>([]);
  const [statuses, setStatuses] = useState<Status[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [countries, setCountries] = useState<Country[]>([]);
  const [categoryFilter, setCategoryFilter] = useState<string[]>([]);
  const [countryFilter, setCountryFilter] = useState<string[]>([]);
  const [staffMin, setStaffMin] = useState<string>("1");
  const [staffMax, setStaffMax] = useState<string>("");
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

  const countryOptions = useMemo(
    () => [...countries].sort((a, b) => a.name.localeCompare(b.name)),
    [countries]
  );

  const sortedCategoryOptions = useMemo(
    () =>
      [...categories]
        .sort((a, b) => a.name.localeCompare(b.name))
        .map((c) => ({ value: c.id, label: c.name })),
    [categories]
  );

  const categoryById = useMemo(() => {
    const map = new Map<string, Category>();
    categories.forEach((c) => map.set(c.id, c));
    return map;
  }, [categories]);

  const filtered = useMemo(() => {
    const min = staffMin.trim() ? parseInt(staffMin, 10) : null;
    const max = staffMax.trim() ? parseInt(staffMax, 10) : null;
    return orgs.filter((o) => {
      if (categoryFilter.length > 0 && (!o.category_id || !categoryFilter.includes(o.category_id)))
        return false;
      if (countryFilter.length > 0 && (!o.country || !countryFilter.includes(o.country)))
        return false;
      const count = (o.staff ?? []).length;
      if (min !== null && count < min) return false;
      if (max !== null && count > max) return false;
      return true;
    });
  }, [orgs, categoryFilter, countryFilter, staffMin, staffMax]);

  const sortedStatuses = [...statuses].sort((a, b) => a.sort_order - b.sort_order);

  async function handleDragEnd(event: DragEndEvent) {
    const { active, over } = event;
    if (!over) return;
    const orgId = active.id as string;
    const newStatusId = over.id as string;
    const org = orgs.find((o) => o.id === orgId);
    if (!org || org.status_id === newStatusId) return;

    // optimistic update
    setOrgs((prev) =>
      prev.map((o) => (o.id === orgId ? { ...o, status_id: newStatusId } : o))
    );
    await updateOrganisation(orgId, { status_id: newStatusId });
    load();
  }

  return (
    <div className="px-8 pb-8">
      <div className="sticky top-0 z-10 -mx-8 bg-slate-50 px-8 pb-4 pt-8">
        <h1 className="mb-4 text-3xl font-semibold text-slate-800">Pipeline</h1>

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
            options={countryOptions.map((c) => ({ value: c.name, label: c.name }))}
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
      ) : (
        <DndContext onDragEnd={handleDragEnd}>
          <div className="flex gap-4 overflow-x-auto pb-4">
            {sortedStatuses.map((status) => (
              <Column
                key={status.id}
                status={status}
                orgs={filtered.filter((o) => o.status_id === status.id)}
                categoryById={categoryById}
              />
            ))}
          </div>
        </DndContext>
      )}
    </div>
  );
}

function Column({
  status,
  orgs,
  categoryById,
}: {
  status: Status;
  orgs: Organisation[];
  categoryById: Map<string, Category>;
}) {
  const { setNodeRef, isOver } = useDroppable({ id: status.id });

  return (
    <div
      ref={setNodeRef}
      className={`w-64 shrink-0 rounded-lg border p-2 ${
        isOver ? "border-slate-400 bg-slate-100" : "border-slate-200 bg-slate-50"
      }`}
    >
      <div className="mb-2 flex items-center justify-between px-1">
        <span className="text-sm font-medium text-slate-700">{status.name}</span>
        <span className="text-xs text-slate-400">{orgs.length}</span>
      </div>
      <div className="space-y-2">
        {orgs.map((org) => (
          <Card key={org.id} org={org} category={org.category_id ? categoryById.get(org.category_id) ?? null : null} />
        ))}
      </div>
    </div>
  );
}

function Card({ org, category }: { org: Organisation; category: Category | null }) {
  const { attributes, listeners, setNodeRef, transform, isDragging } =
    useDraggable({ id: org.id });

  const style = transform
    ? {
        transform: `translate3d(${transform.x}px, ${transform.y}px, 0)`,
        zIndex: 50,
        ...(category?.color ? { borderLeft: `4px solid ${category.color}` } : {}),
      }
    : category?.color
      ? { borderLeft: `4px solid ${category.color}` }
      : undefined;

  return (
    <div
      ref={setNodeRef}
      style={style}
      {...listeners}
      {...attributes}
      className={`cursor-grab rounded border border-slate-200 bg-white p-2 text-sm shadow-sm active:cursor-grabbing ${
        isDragging ? "opacity-50" : ""
      }`}
    >
      <Link
        href={`/call-list?status=${org.status_id}`}
        onClick={(e) => e.stopPropagation()}
        className="font-medium text-slate-800 hover:underline"
      >
        {org.name}
      </Link>
      {org.country && (
        <div className="mt-0.5 flex items-center gap-1 text-xs text-slate-500">
          <CountryFlag country={org.country} className="h-3 w-4 rounded-sm border border-slate-200" />
          {org.country}
        </div>
      )}
    </div>
  );
}
