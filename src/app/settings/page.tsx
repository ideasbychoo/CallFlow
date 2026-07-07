"use client";

import { useEffect, useState } from "react";
import SettingsList from "@/components/SettingsList";
import { fetchSettingsLists } from "@/lib/data";
import type { Status, Department, SeniorityLevel, Category, Country } from "@/types";

export default function SettingsPage() {
  const [statuses, setStatuses] = useState<Status[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [seniorityLevels, setSeniorityLevels] = useState<SeniorityLevel[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [countries, setCountries] = useState<Country[]>([]);
  const [loading, setLoading] = useState(true);

  async function load() {
    const settings = await fetchSettingsLists();
    setStatuses(settings.statuses);
    setDepartments(settings.departments);
    setSeniorityLevels(settings.seniorityLevels);
    setCategories(settings.categories);
    setCountries(settings.countries);
    setLoading(false);
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
    </div>
  );
}
