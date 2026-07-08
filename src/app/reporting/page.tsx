"use client";

import { useEffect, useMemo, useState } from "react";
import { addDays, endOfWeek, format, isSameDay, isWithinInterval, startOfWeek } from "date-fns";
import { fetchAllStatusHistory, fetchSettingsLists, isCallAttemptStatus } from "@/lib/data";
import type { Status } from "@/types";

type HistoryRow = {
  id: string;
  organisation_id: string;
  status_id: string | null;
  changed_at: string;
};

// Weeks run Monday–Sunday.
const WEEK_STARTS_ON = 1 as const;

export default function ReportingPage() {
  const [history, setHistory] = useState<HistoryRow[]>([]);
  const [statuses, setStatuses] = useState<Status[]>([]);
  const [selectedWeekStart, setSelectedWeekStart] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function load() {
      const [historyData, settings] = await Promise.all([
        fetchAllStatusHistory(),
        fetchSettingsLists(),
      ]);
      setHistory(historyData);
      setStatuses(settings.statuses);
      setLoading(false);
    }
    load();
  }, []);

  const sortedStatuses = useMemo(
    () => [...statuses].sort((a, b) => a.sort_order - b.sort_order),
    [statuses]
  );

  // Derive the list of weeks that actually have activity, from the data
  // itself rather than an arbitrary calendar range.
  const availableWeeks = useMemo(() => {
    const weekStarts = new Map<string, Date>();
    for (const row of history) {
      const weekStart = startOfWeek(new Date(row.changed_at), { weekStartsOn: WEEK_STARTS_ON });
      const key = format(weekStart, "yyyy-MM-dd");
      if (!weekStarts.has(key)) weekStarts.set(key, weekStart);
    }
    return [...weekStarts.entries()]
      .sort((a, b) => b[1].getTime() - a[1].getTime()) // newest first
      .map(([key, date]) => ({ key, date }));
  }, [history]);

  useEffect(() => {
    if (!loading && !selectedWeekStart && availableWeeks.length > 0) {
      setSelectedWeekStart(availableWeeks[0].key);
    }
  }, [loading, selectedWeekStart, availableWeeks]);

  const activeWeek = availableWeeks.find((w) => w.key === selectedWeekStart) ?? availableWeeks[0];

  const days = useMemo(() => {
    if (!activeWeek) return [];
    return Array.from({ length: 7 }, (_, i) => addDays(activeWeek.date, i));
  }, [activeWeek]);

  const weekRows = useMemo(() => {
    if (!activeWeek) return [];
    const weekEnd = endOfWeek(activeWeek.date, { weekStartsOn: WEEK_STARTS_ON });
    const weekHistory = history.filter((row) =>
      isWithinInterval(new Date(row.changed_at), { start: activeWeek.date, end: weekEnd })
    );

    return days.map((day) => {
      const dayRows = weekHistory.filter((row) => isSameDay(new Date(row.changed_at), day));
      const statusCounts = new Map<string, number>();
      let callAttempts = 0;
      for (const row of dayRows) {
        const status = statuses.find((s) => s.id === row.status_id);
        if (status) {
          statusCounts.set(status.id, (statusCounts.get(status.id) ?? 0) + 1);
          if (isCallAttemptStatus(status.name)) callAttempts += 1;
        }
      }
      return { day, callAttempts, statusCounts };
    });
  }, [activeWeek, days, history, statuses]);

  const weekTotals = useMemo(() => {
    const totals = new Map<string, number>();
    let callAttempts = 0;
    for (const row of weekRows) {
      callAttempts += row.callAttempts;
      for (const [statusId, count] of row.statusCounts) {
        totals.set(statusId, (totals.get(statusId) ?? 0) + count);
      }
    }
    return { callAttempts, totals };
  }, [weekRows]);

  return (
    <div className="px-8 pb-8">
      <div className="sticky top-0 z-10 -mx-8 bg-slate-50 px-8 pb-4 pt-8">
        <div className="mb-4 flex items-center justify-between">
          <h1 className="text-3xl font-semibold text-slate-800">Reporting</h1>
          {availableWeeks.length > 0 && (
            <select
              value={selectedWeekStart ?? ""}
              onChange={(e) => setSelectedWeekStart(e.target.value)}
              className="rounded border border-slate-300 bg-white px-3 py-2 text-sm text-slate-800 focus:border-slate-500 focus:outline-none"
            >
              {availableWeeks.map((w) => (
                <option key={w.key} value={w.key}>
                  Week of {format(w.date, "d MMM yyyy")}
                </option>
              ))}
            </select>
          )}
        </div>
        <p className="text-sm text-slate-500">
          Daily call attempts and status changes, based on activity recorded in the database.
        </p>
      </div>

      {loading ? (
        <p className="text-sm text-slate-400">Loading…</p>
      ) : availableWeeks.length === 0 ? (
        <p className="text-sm text-slate-400">No activity recorded yet — change an organisation's status to start seeing data here.</p>
      ) : (
        <div className="overflow-x-auto rounded-lg border border-slate-200 bg-white">
          <table className="w-full border-collapse text-xs">
            <thead className="bg-slate-100 text-left text-slate-600">
              <tr>
                <th className="whitespace-nowrap border-b border-slate-200 px-3 py-2 font-medium">Day</th>
                <th className="whitespace-nowrap border-b border-slate-200 px-3 py-2 font-medium">Call attempts</th>
                {sortedStatuses.map((s) => (
                  <th key={s.id} className="whitespace-nowrap border-b border-slate-200 px-3 py-2 font-medium">
                    {s.name}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {weekRows.map(({ day, callAttempts, statusCounts }) => (
                <tr key={day.toISOString()} className="border-b border-slate-100 hover:bg-slate-50">
                  <td className="whitespace-nowrap px-3 py-2 font-medium text-slate-700">
                    {format(day, "EEE d MMM")}
                  </td>
                  <td className="px-3 py-2 text-center text-slate-800">{callAttempts || "—"}</td>
                  {sortedStatuses.map((s) => (
                    <td key={s.id} className="px-3 py-2 text-center text-slate-600">
                      {statusCounts.get(s.id) ?? "—"}
                    </td>
                  ))}
                </tr>
              ))}
              <tr className="bg-slate-50 font-medium text-slate-800">
                <td className="whitespace-nowrap px-3 py-2">Week total</td>
                <td className="px-3 py-2 text-center">{weekTotals.callAttempts || "—"}</td>
                {sortedStatuses.map((s) => (
                  <td key={s.id} className="px-3 py-2 text-center">
                    {weekTotals.totals.get(s.id) ?? "—"}
                  </td>
                ))}
              </tr>
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
