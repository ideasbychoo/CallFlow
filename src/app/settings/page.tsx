"use client";

import { useEffect, useState } from "react";
import SettingsList from "@/components/SettingsList";
import { fetchSettingsLists } from "@/lib/data";
import type { Status, Department, SeniorityLevel, Category, Country, SourceType, Segment } from "@/types";

export default function SettingsPage() {
  const [statuses, setStatuses] = useState<Status[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [seniorityLevels, setSeniorityLevels] = useState<SeniorityLevel[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [countries, setCountries] = useState<Country[]>([]);
  const [sourceTypes, setSourceTypes] = useState<SourceType[]>([]);
  const [segments, setSegments] = useState<Segment[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  async function load() {
    setLoadError(null);
    try {
      const settings = await fetchSettingsLists();
      setStatuses(settings.statuses);
      setDepartments(settings.departments);
      setSeniorityLevels(settings.seniorityLevels);
      setCategories(settings.categories);
      setCountries(settings.countries);
      setSourceTypes(settings.sourceTypes);
      setSegments(settings.segments);
    } catch (err) {
      console.error(err);
      setLoadError(err instanceof Error ? err.message : "Failed to load data.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  if (loading) {
    return <p className="p-8 text-sm text-slate-400">Loading…</p>;
  }

  return (
    <div className="mx-auto max-w-2xl px-8 py-8">
      <h1 className="sticky top-0 z-10 -mx-8 mb-6 bg-slate-50 px-8 py-2 text-3xl font-semibold text-slate-800">
        Settings
      </h1>

      {loadError && (
        <div className="mb-4 flex items-center justify-between rounded border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          <span>Couldn&rsquo;t load data: {loadError}</span>
          <button onClick={load} className="ml-4 shrink-0 rounded border border-red-300 bg-white px-3 py-1 font-medium hover:bg-red-50">
            Retry
          </button>
        </div>
      )}

      <SettingsList
        title="Statuses"
        table="statuses"
        items={statuses}
        onChanged={load}
      />
      <SettingsList
        title="Prospects' Departments"
        table="departments"
        items={departments}
        onChanged={load}
      />
      <SettingsList
        title="Prospects' Seniority Levels"
        table="seniority_levels"
        items={seniorityLevels}
        onChanged={load}
      />
      <SettingsList
        title="Prospect Categories"
        table="categories"
        items={categories}
        onChanged={load}
        sortAlphabetically
        showColor
      />
      <SettingsList
        title="Countries"
        table="countries"
        items={countries}
        onChanged={load}
        sortAlphabetically
      />
      <SettingsList
        title="Segments"
        table="segments"
        items={segments}
        onChanged={load}
        sortAlphabetically
      />
      <SettingsList
        title="Source Types"
        table="source_types"
        items={sourceTypes}
        onChanged={load}
      />
    </div>
  );
}
