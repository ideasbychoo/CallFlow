"use client";

import { useEffect, useMemo, useState } from "react";
import SettingsList from "@/components/SettingsList";
import MultiSelectFilter from "@/components/MultiSelectFilter";
import {
  fetchSettingsLists,
  setStatusCountsAsCallAttempt,
  createReportGroup,
  renameReportGroup,
  setReportGroupStatuses,
  deleteReportGroup,
} from "@/lib/data";
import type { Status, Department, SeniorityLevel, Category, Country, SourceType, Segment, ReportGroup } from "@/types";

export default function SettingsPage() {
  const [statuses, setStatuses] = useState<Status[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [seniorityLevels, setSeniorityLevels] = useState<SeniorityLevel[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [countries, setCountries] = useState<Country[]>([]);
  const [sourceTypes, setSourceTypes] = useState<SourceType[]>([]);
  const [segments, setSegments] = useState<Segment[]>([]);
  const [reportGroups, setReportGroups] = useState<ReportGroup[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);
  const [testing, setTesting] = useState(false);
  const [testResult, setTestResult] = useState<{ success: boolean; message: string; warnings?: string[] } | null>(null);

  async function runIngestTest() {
    setTesting(true);
    setTestResult(null);
    try {
      const res = await fetch("/api/ingest/test-connection", { method: "POST" });
      const data = await res.json();
      setTestResult(data);
    } catch (err) {
      setTestResult({
        success: false,
        message: err instanceof Error ? err.message : "Something went wrong running the test.",
      });
    } finally {
      setTesting(false);
    }
  }

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
      setReportGroups(settings.reportGroups);
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

  const sortedStatusOptions = useMemo(
    () =>
      [...statuses]
        .sort((a, b) => a.sort_order - b.sort_order)
        .map((s) => ({ value: s.id, label: s.name })),
    [statuses]
  );

  async function handleAddReportGroup() {
    await createReportGroup("New group", []);
    load();
  }

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

      <div className="mb-6 rounded-lg border border-slate-200 bg-white p-4">
        <h2 className="mb-1 text-sm font-semibold text-slate-800">Prospecting agent connection</h2>
        <p className="mb-3 text-xs text-slate-500">
          Checks that the Claude Code routine (or any other agent) can write new prospects into
          CallFlow. This creates a harmless test record and deletes it immediately — nothing
          you need to clean up.
        </p>
        <button
          onClick={runIngestTest}
          disabled={testing}
          className="rounded bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700 disabled:opacity-50"
        >
          {testing ? "Testing\u2026" : "Test ingest connection"}
        </button>
        {testResult && (
          <div
            className={`mt-3 rounded border px-3 py-2 text-sm ${
              testResult.success
                ? "border-green-200 bg-green-50 text-green-700"
                : "border-red-200 bg-red-50 text-red-700"
            }`}
          >
            <div>{testResult.success ? "\u2705 " : "\u274c "}{testResult.message}</div>
            {testResult.warnings && testResult.warnings.length > 0 && (
              <ul className="mt-1 list-disc pl-5">
                {testResult.warnings.map((w, i) => (
                  <li key={i}>{w}</li>
                ))}
              </ul>
            )}
          </div>
        )}
      </div>

      <SettingsList
        title="Statuses"
        table="statuses"
        items={statuses}
        onChanged={load}
        extraToggle={{
          label: "Counts as a call attempt",
          getValue: (s) => s.counts_as_call_attempt,
          onToggle: (s, value) => setStatusCountsAsCallAttempt(s.id, value),
        }}
      />

      <div className="mb-8">
        <h2 className="mb-2 text-lg font-semibold text-slate-800">Reporting summary columns</h2>
        <p className="mb-2 text-xs text-slate-500">
          Group several statuses together into a named column on the Reporting tab (e.g. &ldquo;Chatted&rdquo;).
        </p>
        <div className="divide-y divide-slate-100 rounded border border-slate-200 bg-white">
          {reportGroups.map((group) => (
            <div key={group.id} className="flex items-center gap-2 px-3 py-2">
              <input
                type="text"
                defaultValue={group.name}
                onBlur={(e) => {
                  if (e.target.value.trim() && e.target.value !== group.name) {
                    renameReportGroup(group.id, e.target.value.trim()).then(load);
                  }
                }}
                className="w-40 shrink-0 rounded border border-transparent bg-transparent text-sm font-medium text-slate-800 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
              />
              <div className="flex-1">
                <MultiSelectFilter
                  label="Statuses"
                  options={sortedStatusOptions}
                  selected={(group.statuses ?? []).map((s) => s.id)}
                  onChange={(ids) => setReportGroupStatuses(group.id, ids).then(load)}
                />
              </div>
              <button
                onClick={() => {
                  if (confirm(`Remove the "${group.name}" summary column?`)) {
                    deleteReportGroup(group.id).then(load);
                  }
                }}
                className="text-xs text-slate-300 hover:text-red-500"
              >
                ✕
              </button>
            </div>
          ))}
          {reportGroups.length === 0 && (
            <p className="px-3 py-2 text-sm text-slate-400">No summary columns yet.</p>
          )}
        </div>
        <button
          onClick={handleAddReportGroup}
          className="mt-2 text-sm text-slate-500 hover:text-slate-800"
        >
          + Add another
        </button>
      </div>

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
