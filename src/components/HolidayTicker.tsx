"use client";

import { useState } from "react";

export type TodayHoliday = {
  id: string;
  name: string;
  country: { name: string } | null;
};

export default function HolidayTicker({ holidays }: { holidays: TodayHoliday[] }) {
  const [dismissed, setDismissed] = useState(false);

  if (dismissed || holidays.length === 0) return null;

  return (
    <div className="flex shrink-0 items-center justify-between gap-3 border-b border-amber-200 bg-amber-50 px-4 py-2 text-sm text-amber-800 sm:px-8">
      <span>
        🎉 Public holiday today —{" "}
        {holidays
          .map((h) => `${h.country?.name ?? "Unknown country"}: ${h.name}`)
          .join(" · ")}
      </span>
      <button
        onClick={() => setDismissed(true)}
        aria-label="Dismiss"
        className="shrink-0 text-amber-600 hover:text-amber-900"
      >
        ✕
      </button>
    </div>
  );
}
