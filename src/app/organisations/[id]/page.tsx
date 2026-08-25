"use client";

import { useEffect, useState } from "react";
import { useParams } from "next/navigation";
import OrganisationCard from "@/components/OrganisationCard";
import {
  fetchOrganisationById,
  fetchSettingsLists,
  fetchAllSources,
  fetchAllEmailTemplates,
} from "@/lib/data";
import type {
  Organisation,
  Status,
  Department,
  SeniorityLevel,
  Category,
  Country,
  SourceType,
  Source,
  Segment,
  EmailTemplate,
} from "@/types";

export default function OrganisationProfilePage() {
  const params = useParams<{ id: string }>();
  const orgId = params.id;

  const [org, setOrg] = useState<Organisation | null>(null);
  const [statuses, setStatuses] = useState<Status[]>([]);
  const [departments, setDepartments] = useState<Department[]>([]);
  const [seniorityLevels, setSeniorityLevels] = useState<SeniorityLevel[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [countries, setCountries] = useState<Country[]>([]);
  const [sourceTypes, setSourceTypes] = useState<SourceType[]>([]);
  const [sources, setSources] = useState<Source[]>([]);
  const [segments, setSegments] = useState<Segment[]>([]);
  const [emailTemplates, setEmailTemplates] = useState<EmailTemplate[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState<string | null>(null);

  async function load() {
    setLoadError(null);
    try {
      const [orgData, settings, sourcesData, emailTemplatesData] = await Promise.all([
        fetchOrganisationById(orgId),
        fetchSettingsLists(),
        fetchAllSources(),
        fetchAllEmailTemplates(),
      ]);
      setOrg(orgData);
      setStatuses(settings.statuses);
      setDepartments(settings.departments);
      setSeniorityLevels(settings.seniorityLevels);
      setCategories(settings.categories);
      setCountries(settings.countries);
      setSourceTypes(settings.sourceTypes);
      setSources(sourcesData);
      setSegments(settings.segments);
      setEmailTemplates(emailTemplatesData);
    } catch (err) {
      console.error(err);
      setLoadError(err instanceof Error ? err.message : "Failed to load data.");
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [orgId]);

  return (
    <div className="mx-auto max-w-3xl px-4 sm:px-8 py-8">
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
      ) : !org ? (
        <p className="text-sm text-slate-400">Organisation not found.</p>
      ) : (
        <OrganisationCard
          org={org}
          statuses={statuses}
          departments={departments}
          seniorityLevels={seniorityLevels}
          categories={categories}
          countries={countries}
          sourceTypes={sourceTypes}
          sources={sources}
          segments={segments}
          emailTemplates={emailTemplates}
          defaultExpanded
          hideFocusButton
          onChanged={load}
        />
      )}
    </div>
  );
}
