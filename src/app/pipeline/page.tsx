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
import { fetchOrganisations, fetchSettingsLists, updateOrganisation } from "@/lib/data";
import type { Organisation, Status, Category } from "@/types";

export default function PipelinePage() {
  const [orgs, setOrgs] = useState<Organisation[]>([]);
  const [statuses, setStatuses] = useState<Status[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [categoryFilter, setCategoryFilter] = useState<string[]>([]);
  const [countryFilter, setCountryFilter] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    const [orgData, settings] = await Promise.all([
      fetchOrganisations(),
      fetchSettingsLists(),
    ]);
    setOrgs(orgData);
    setStatuses(settings.statuses);
    setCategories(settings.categories);
    setLoading(false);
  }

  useEffect(() => {
    load();
  }, []);

  const countryOptions = useMemo(() => {
    const set = new Set<string>();
    orgs.forEach((o) => o.country && set.add(o.country));
    return Array.from(set).sort();
  }, [orgs]);

  const filtered = useMemo(() => {
    return orgs.filter((o) => {
      if (categoryFilter.length > 0 && (!o.category_id || !categoryFilter.includes(o.category_id)))
        return false;
      if (countryFilter.length > 0 && (!o.country || !countryFilter.includes(o.country)))
        return false;
      return true;
    });
  }, [orgs, categoryFilter, countryFilter]);

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
    <div className="px-8 py-8">
      <h1 className="mb-4 text-3xl font-semibold text-slate-800">Pipeline</h1>

      <div className="mb-6 flex flex-wrap items-center gap-3">
        <span className="text-sm text-slate-500">Filters:</span>
        <MultiSelectFilter
          label="Category"
          options={categories.map((c) => ({ value: c.id, label: c.name }))}
          selected={categoryFilter}
          onChange={setCategoryFilter}
        />
        <MultiSelectFilter
          label="Country"
          options={countryOptions.map((c) => ({ value: c, label: c }))}
          selected={countryFilter}
          onChange={setCountryFilter}
        />
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
              />
            ))}
          </div>
        </DndContext>
      )}
    </div>
  );
}

function Column({ status, orgs }: { status: Status; orgs: Organisation[] }) {
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
          <Card key={org.id} org={org} />
        ))}
      </div>
    </div>
  );
}

function Card({ org }: { org: Organisation }) {
  const { attributes, listeners, setNodeRef, transform, isDragging } =
    useDraggable({ id: org.id });

  const style = transform
    ? {
        transform: `translate3d(${transform.x}px, ${transform.y}px, 0)`,
        zIndex: 50,
      }
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
      {org.country && <div className="text-xs text-slate-500">{org.country}</div>}
    </div>
  );
}
