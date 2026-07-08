"use client";

import { useEffect, useMemo, useState } from "react";
import { EditableText } from "@/components/EditableField";
import MultiSelectFilter from "@/components/MultiSelectFilter";
import {
  fetchAllSources,
  fetchSettingsLists,
  createSource,
  updateSource,
  setSourceTypes,
  deleteSource,
} from "@/lib/data";
import type { Source, SourceType } from "@/types";

export default function SourcesPage() {
  const [sources, setSources] = useState<Source[]>([]);
  const [sourceTypes, setSourceTypes_] = useState<SourceType[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  async function load() {
    setLoadError(null);
    try {
      const [sourcesData, settings] = await Promise.all([
        fetchAllSources(),
        fetchSettingsLists(),
      ]);
      setSources(sourcesData);
      setSourceTypes_(settings.sourceTypes);
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

  const sortedTypes = useMemo(
    () => [...sourceTypes].sort((a, b) => a.sort_order - b.sort_order),
    [sourceTypes]
  );
  const typeOptions = useMemo(
    () => sortedTypes.map((t) => ({ value: t.id, label: t.name })),
    [sortedTypes]
  );

  async function handleAdd() {
    if (sourceTypes.length === 0) {
      alert("Add at least one Source Type in Settings first.");
      return;
    }
    try {
      await createSource({
        name: "New source",
        source_type_ids: [sourceTypes[0].id],
      });
      load();
    } catch (err) {
      console.error(err);
      alert("Couldn't add the new source. Please try again.");
    }
  }

  async function handleTypesChange(source: Source, typeIds: string[]) {
    if (typeIds.length === 0) {
      alert("A source must have at least one Source Type.");
      return;
    }
    await setSourceTypes(source.id, typeIds);
    load();
  }

  const cellClass =
    "rounded border border-transparent bg-transparent px-1 py-0.5 text-xs text-slate-800 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none";

  return (
    <div className="px-8 pb-8">
      <div className="sticky top-0 z-10 -mx-8 bg-slate-50 px-8 pb-4 pt-8">
        <div className="mb-4 flex items-center justify-between">
          <h1 className="text-3xl font-semibold text-slate-800">Sources</h1>
          <button
            onClick={handleAdd}
            className="rounded bg-slate-800 px-4 py-2 text-sm font-medium text-white hover:bg-slate-700"
          >
            + Add source
          </button>
        </div>
        <p className="text-sm text-slate-500">
          Specific places prospects were found, e.g. &ldquo;Third Sector Charity Awards&rdquo; or &ldquo;NAVCA&rdquo;.
          Each source needs at least one Source Type — manage that list in Settings.
        </p>
      </div>

      {loadError && (
        <div className="mb-4 flex items-center justify-between rounded border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          <span>Couldn&rsquo;t load data: {loadError}</span>
          <button onClick={load} className="ml-4 shrink-0 rounded border border-red-300 bg-white px-3 py-1 font-medium hover:bg-red-50">
            Retry
          </button>
        </div>
      )}

      {loading ? (
        <p className="text-sm text-slate-400">Loading…</p>
      ) : (
        <div className="overflow-x-auto rounded-lg border border-slate-200 bg-white">
          <table className="w-full min-w-[700px] border-collapse text-xs">
            <thead className="sticky top-0 z-[5] bg-slate-100 text-left text-slate-600">
              <tr>
                {["Name", "Source Type(s)", "Website", ""].map((h) => (
                  <th key={h} className="whitespace-nowrap border-b border-slate-200 px-2 py-2 font-medium">
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {sources.map((source) => (
                <tr key={source.id} className="border-b border-slate-100 align-top hover:bg-slate-50">
                  <td className="min-w-[220px] px-2 py-1">
                    <EditableText
                      value={source.name}
                      onSave={(v) => updateSource(source.id, { name: v }).then(load)}
                      className={cellClass + " font-medium"}
                    />
                  </td>
                  <td className="min-w-[220px] px-2 py-1">
                    <MultiSelectFilter
                      label="Types"
                      options={typeOptions}
                      selected={(source.source_types ?? []).map((t) => t.id)}
                      onChange={(ids) => handleTypesChange(source, ids)}
                    />
                  </td>
                  <td className="min-w-[240px] px-2 py-1">
                    <EditableText
                      value={source.website}
                      onSave={(v) => updateSource(source.id, { website: v }).then(load)}
                      placeholder="https://…"
                      className={cellClass}
                    />
                  </td>
                  <td className="px-2 py-1">
                    <button
                      onClick={() => {
                        if (confirm(`Delete ${source.name}?`)) {
                          deleteSource(source.id).then(load);
                        }
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
