"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import CategoryChip from "@/components/CategoryChip";
import CountryFlag from "@/components/CountryFlag";
import { fetchResearchOrgFlags, fetchSettingsLists } from "@/lib/data";
import type { ResearchOrgFlag, Segment, Country, Status, Department } from "@/types";

type Counts = { ready: number; withPhone: number; withPriorityRole: number };

function emptyCounts(): Counts {
  return { ready: 0, withPhone: 0, withPriorityRole: 0 };
}

// A row only ever counts towards these numbers if it's in a "Call or Chase"
// status -- that's the shared precondition across every column in every
// table on this page.
function tally(counts: Counts, row: ResearchOrgFlag) {
  if (!row.is_call_or_chase) return;
  if (row.has_phone && row.has_priority_staff) counts.ready += 1;
  if (row.has_phone) counts.withPhone += 1;
  if (row.has_priority_staff) counts.withPriorityRole += 1;
}

// Builds the Call List URL for a given cell. call_or_chase is always
// implied (every column on this page requires it). hasPhone/priorityRole
// are passed explicitly as true/false (never omitted) so the destination
// page's filters exactly match what this column actually counted --
// otherwise Call List's own default of "phone present only" would silently
// add a phone requirement to the "priority role-holder" column, which
// doesn't require one.
function callListHref(opts: {
  hasPhone: boolean;
  priorityRole: boolean;
  segmentId?: string;
  country?: string;
}) {
  const params = new URLSearchParams();
  params.set("call_or_chase", "true");
  params.set("has_phone", String(opts.hasPhone));
  params.set("priority_role", String(opts.priorityRole));
  if (opts.segmentId) params.set("segment", opts.segmentId);
  if (opts.country) params.set("country", opts.country);
  return `/call-list?${params.toString()}`;
}

function CountLink({ count, href }: { count: number; href: string }) {
  if (count === 0) {
    return <span className="text-slate-400">0</span>;
  }
  return (
    <Link href={href} className="font-medium text-blue-600 hover:text-blue-800 hover:underline">
      {count}
    </Link>
  );
}

export default function ResearchPage() {
  const [flags, setFlags] = useState<ResearchOrgFlag[]>([]);
  const [segments, setSegments] = useState<Segment[]>([]);
  const [countries, setCountries] = useState<Country[]>([]);
  const [statuses, setStatuses] = useState<Status[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  async function load() {
    setLoadError(null);
    try {
      const [flagRows, settings] = await Promise.all([fetchResearchOrgFlags(), fetchSettingsLists()]);
      setFlags(flagRows);
      setSegments(settings.segments);
      setCountries(settings.countries);
      setStatuses(settings.statuses);
      setDepartments(settings.departments);
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

  const sortedSegments = useMemo(
    () => [...segments].sort((a, b) => a.name.localeCompare(b.name)),
    [segments]
  );
  const sortedCountries = useMemo(
    () => [...countries].sort((a, b) => a.name.localeCompare(b.name)),
    [countries]
  );

  const noCallOrChaseConfigured = useMemo(
    () => statuses.length > 0 && !statuses.some((s) => s.is_call_or_chase),
    [statuses]
  );
  const noPriorityDeptConfigured = useMemo(
    () => departments.length > 0 && !departments.some((d) => d.is_priority_role_holder),
    [departments]
  );

  // Everything below is a single pass over `flags` (currently ~500 rows,
  // just a handful of booleans each) grouped into plain objects -- no
  // per-cell queries. See migration 022 / research_org_flags for where the
  // actual per-organisation computation happens.
  const perSegment = useMemo(() => {
    const map = new Map<string, Counts>();
    for (const seg of sortedSegments) map.set(seg.id, emptyCounts());
    for (const row of flags) {
      if (!row.segment_id) continue;
      const counts = map.get(row.segment_id);
      if (counts) tally(counts, row);
    }
    return map;
  }, [flags, sortedSegments]);

  const perCountry = useMemo(() => {
    const map = new Map<string, Counts>();
    for (const c of sortedCountries) map.set(c.name, emptyCounts());
    for (const row of flags) {
      if (!row.country) continue;
      const counts = map.get(row.country);
      if (counts) tally(counts, row);
    }
    return map;
  }, [flags, sortedCountries]);

  const crossTab = useMemo(() => {
    // Keyed "segmentId::country" -> ready-to-contact count only (the
    // cross-tab is just the first column, per the spec).
    const map = new Map<string, number>();
    for (const row of flags) {
      if (!row.segment_id || !row.country || !row.is_call_or_chase) continue;
      if (!(row.has_phone && row.has_priority_staff)) continue;
      const key = `${row.segment_id}::${row.country}`;
      map.set(key, (map.get(key) ?? 0) + 1);
    }
    return map;
  }, [flags]);

  return (
    <div className="px-4 pb-8 sm:px-8">
      <div className="sticky top-0 z-10 -mx-4 bg-slate-50 px-4 pb-4 pt-8 sm:-mx-8 sm:px-8">
        <h1 className="text-3xl font-semibold text-slate-800">Research</h1>
        <p className="mt-1 text-sm text-slate-500">
          A snapshot of prospect research so far -- where the organisations ready for a call
          actually are, by segment and country.
        </p>
      </div>

      {loadError && (
        <div className="mb-4 rounded border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {loadError}{" "}
          <button onClick={load} className="font-medium underline">
            Retry
          </button>
        </div>
      )}

      {loading ? (
        <p className="text-sm text-slate-500">Loading…</p>
      ) : (
        <>
          {(noCallOrChaseConfigured || noPriorityDeptConfigured) && (
            <div className="mb-6 rounded border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-800">
              {noCallOrChaseConfigured && (
                <p>
                  No Status is currently marked &ldquo;Call or Chase&rdquo; -- every number below will
                  be 0 until you set that in{" "}
                  <Link href="/settings" className="underline">
                    Settings
                  </Link>
                  .
                </p>
              )}
              {noPriorityDeptConfigured && (
                <p>
                  No Department is currently marked &ldquo;Priority role-holder&rdquo; -- the
                  priority-role columns below will be 0 until you set that in{" "}
                  <Link href="/settings" className="underline">
                    Settings
                  </Link>
                  .
                </p>
              )}
            </div>
          )}

          <h2 className="mb-2 text-lg font-semibold text-slate-800">Ready to contact: per segment and country</h2>
          <p className="mb-3 text-sm text-slate-500">
            Organisations in a Call-or-Chase status with both a phone number and a priority
            role-holder identified.
          </p>
          <div className="mb-10 overflow-x-auto rounded border border-slate-200 bg-white">
            <table className="w-full border-collapse text-sm">
              <thead>
                <tr>
                  <th className="sticky left-0 z-10 border-b border-r border-slate-200 bg-white p-3 text-left"></th>
                  {sortedCountries.map((c) => (
                    <th
                      key={c.name}
                      className="whitespace-nowrap border-b border-slate-200 p-3 text-left font-medium text-slate-700"
                    >
                      <span className="flex items-center gap-1.5">
                        <CountryFlag country={c.name} />
                        {c.name}
                      </span>
                    </th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {sortedSegments.map((seg) => (
                  <tr key={seg.id}>
                    <td className="sticky left-0 z-10 whitespace-nowrap border-b border-r border-slate-200 bg-white p-3">
                      <CategoryChip name={seg.name} color={seg.color} />
                    </td>
                    {sortedCountries.map((c) => {
                      const count = crossTab.get(`${seg.id}::${c.name}`) ?? 0;
                      return (
                        <td key={c.name} className="border-b border-slate-100 p-3">
                          <CountLink
                            count={count}
                            href={callListHref({
                              hasPhone: true,
                              priorityRole: true,
                              segmentId: seg.id,
                              country: c.name,
                            })}
                          />
                        </td>
                      );
                    })}
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <h2 className="mb-2 text-lg font-semibold text-slate-800">Hit List per segment</h2>
          <div className="mb-10 overflow-x-auto rounded border border-slate-200 bg-white">
            <table className="w-full border-collapse text-sm">
              <thead>
                <tr>
                  <th className="border-b border-slate-200 p-3 text-left font-medium text-slate-700">Segment</th>
                  <th className="border-b border-slate-200 p-3 text-left font-medium text-slate-700">
                    Ready to contact: Orgs to contact (with phone number and a priority role-holder
                    identified)
                  </th>
                  <th className="border-b border-slate-200 p-3 text-left font-medium text-slate-700">
                    Orgs to contact (with phone number)
                  </th>
                  <th className="border-b border-slate-200 p-3 text-left font-medium text-slate-700">
                    Orgs to contact (with a priority role-holder identified)
                  </th>
                </tr>
              </thead>
              <tbody>
                {sortedSegments.map((seg) => {
                  const counts = perSegment.get(seg.id) ?? emptyCounts();
                  return (
                    <tr key={seg.id}>
                      <td className="whitespace-nowrap border-b border-slate-100 p-3">
                        <CategoryChip name={seg.name} color={seg.color} />
                      </td>
                      <td className="border-b border-slate-100 p-3">
                        <CountLink
                          count={counts.ready}
                          href={callListHref({ hasPhone: true, priorityRole: true, segmentId: seg.id })}
                        />
                      </td>
                      <td className="border-b border-slate-100 p-3">
                        <CountLink
                          count={counts.withPhone}
                          href={callListHref({ hasPhone: true, priorityRole: false, segmentId: seg.id })}
                        />
                      </td>
                      <td className="border-b border-slate-100 p-3">
                        <CountLink
                          count={counts.withPriorityRole}
                          href={callListHref({ hasPhone: false, priorityRole: true, segmentId: seg.id })}
                        />
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          <h2 className="mb-2 text-lg font-semibold text-slate-800">Hit List per country</h2>
          <div className="mb-10 overflow-x-auto rounded border border-slate-200 bg-white">
            <table className="w-full border-collapse text-sm">
              <thead>
                <tr>
                  <th className="border-b border-slate-200 p-3 text-left font-medium text-slate-700">Country</th>
                  <th className="border-b border-slate-200 p-3 text-left font-medium text-slate-700">
                    Ready to contact: Orgs to contact (with phone number and a priority role-holder
                    identified)
                  </th>
                  <th className="border-b border-slate-200 p-3 text-left font-medium text-slate-700">
                    Orgs to contact (with phone number)
                  </th>
                  <th className="border-b border-slate-200 p-3 text-left font-medium text-slate-700">
                    Orgs to contact (with a priority role-holder identified)
                  </th>
                </tr>
              </thead>
              <tbody>
                {sortedCountries.map((c) => {
                  const counts = perCountry.get(c.name) ?? emptyCounts();
                  return (
                    <tr key={c.name}>
                      <td className="whitespace-nowrap border-b border-slate-100 p-3">
                        <span className="flex items-center gap-1.5">
                          <CountryFlag country={c.name} />
                          {c.name}
                        </span>
                      </td>
                      <td className="border-b border-slate-100 p-3">
                        <CountLink
                          count={counts.ready}
                          href={callListHref({ hasPhone: true, priorityRole: true, country: c.name })}
                        />
                      </td>
                      <td className="border-b border-slate-100 p-3">
                        <CountLink
                          count={counts.withPhone}
                          href={callListHref({ hasPhone: true, priorityRole: false, country: c.name })}
                        />
                      </td>
                      <td className="border-b border-slate-100 p-3">
                        <CountLink
                          count={counts.withPriorityRole}
                          href={callListHref({ hasPhone: false, priorityRole: true, country: c.name })}
                        />
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </>
      )}
    </div>
  );
}
