"use client";

import * as Flags from "country-flag-icons/react/3x2";
import { countryToIso } from "@/lib/countries";

export default function CountryFlag({
  country,
  className = "h-3.5 w-5 rounded-sm border border-slate-200",
}: {
  country: string | null | undefined;
  className?: string;
}) {
  const iso = countryToIso(country);
  if (!iso) return null;

  const FlagComponent = (Flags as unknown as Record<string, React.ComponentType<{ className?: string; title?: string }>>)[iso];
  if (!FlagComponent) return null;

  return <FlagComponent className={className} title={country ?? undefined} />;
}
