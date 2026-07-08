import { createClient } from "@/lib/supabase/client";
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
  StaffMember,
} from "@/types";

const ORG_SELECT = `
  *,
  category:categories(id, name, sort_order),
  segment:segments(id, name, sort_order),
  source_type:source_types(id, name, sort_order),
  source:sources(id, name, website),
  office_locations(*),
  staff(*),
  status_history(id, status_id, changed_at)
`;

export async function fetchOrganisations(): Promise<Organisation[]> {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("organisations")
    .select(ORG_SELECT)
    .order("date_spotted", { ascending: false });

  if (error) throw error;
  return (data ?? []) as unknown as Organisation[];
}

export async function fetchSettingsLists(): Promise<{
  statuses: Status[];
  departments: Department[];
  seniorityLevels: SeniorityLevel[];
  categories: Category[];
  countries: Country[];
  sourceTypes: SourceType[];
  segments: Segment[];
}> {
  const supabase = createClient();
  const [statuses, departments, seniorityLevels, categories, countries, sourceTypes, segments] =
    await Promise.all([
      supabase.from("statuses").select("*").order("sort_order"),
      supabase.from("departments").select("*").order("sort_order"),
      supabase.from("seniority_levels").select("*").order("sort_order"),
      supabase.from("categories").select("*").order("sort_order"),
      supabase.from("countries").select("*").order("sort_order"),
      supabase.from("source_types").select("*").order("sort_order"),
      supabase.from("segments").select("*").order("sort_order"),
    ]);

  return {
    statuses: (statuses.data ?? []) as Status[],
    departments: (departments.data ?? []) as Department[],
    seniorityLevels: (seniorityLevels.data ?? []) as SeniorityLevel[],
    categories: (categories.data ?? []) as Category[],
    countries: (countries.data ?? []) as Country[],
    sourceTypes: (sourceTypes.data ?? []) as SourceType[],
    segments: (segments.data ?? []) as Segment[],
  };
}

export async function updateOrganisation(
  id: string,
  fields: Partial<Organisation>
) {
  const supabase = createClient();
  const { error } = await supabase
    .from("organisations")
    .update(fields)
    .eq("id", id);
  if (error) throw error;
}

export async function createOrganisation(
  fields: Partial<Organisation>
): Promise<string> {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("organisations")
    .insert(fields)
    .select("id")
    .single();
  if (error) throw error;
  return data.id as string;
}

export async function deleteOrganisation(id: string) {
  const supabase = createClient();
  const { error } = await supabase.from("organisations").delete().eq("id", id);
  if (error) throw error;
}

export async function fetchAllStaff(): Promise<
  (StaffMember & { organisation?: { id: string; name: string } | null })[]
> {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("staff")
    .select("*, organisation:organisations(id, name)")
    .order("full_name");
  if (error) throw error;
  return (data ?? []) as unknown as (StaffMember & {
    organisation?: { id: string; name: string } | null;
  })[];
}

export async function fetchAllOrganisationsBasic(): Promise<
  { id: string; name: string }[]
> {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("organisations")
    .select("id, name")
    .order("name");
  if (error) throw error;
  return (data ?? []) as { id: string; name: string }[];
}

export async function updateStaffMember(id: string, fields: Record<string, unknown>) {
  const supabase = createClient();
  const { error } = await supabase.from("staff").update(fields).eq("id", id);
  if (error) throw error;
}

export async function upsertStaffMember(fields: Record<string, unknown>) {
  const supabase = createClient();
  const { error } = await supabase.from("staff").upsert(fields);
  if (error) throw error;
}

// Explicit insert for creating a brand-new staff member (as opposed to
// upsertStaffMember, which is used for editing an existing row). Returns the
// new row's id so callers can scroll to / focus it.
export async function addStaffMember(fields: Record<string, unknown>): Promise<string> {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("staff")
    .insert(fields)
    .select("id")
    .single();
  if (error) throw error;
  return data.id as string;
}

export async function deleteStaffMember(id: string) {
  const supabase = createClient();
  const { error } = await supabase.from("staff").delete().eq("id", id);
  if (error) throw error;
}

export async function upsertOfficeLocation(fields: Record<string, unknown>) {
  const supabase = createClient();
  const { error } = await supabase.from("office_locations").upsert(fields);
  if (error) throw error;
}

export async function deleteOfficeLocation(id: string) {
  const supabase = createClient();
  const { error } = await supabase
    .from("office_locations")
    .delete()
    .eq("id", id);
  if (error) throw error;
}

// Generic helpers for the four Settings lists (statuses/departments/seniority/categories)
export type SettingsTable =
  | "statuses"
  | "departments"
  | "seniority_levels"
  | "categories"
  | "countries"
  | "source_types"
  | "segments";

export async function addSettingsItem(table: SettingsTable, name: string, sort_order: number) {
  const supabase = createClient();
  const { error } = await supabase.from(table).insert({ name, sort_order });
  if (error) throw error;
}

export async function renameSettingsItem(
  table: SettingsTable,
  id: string,
  name: string
) {
  const supabase = createClient();
  const { error } = await supabase.from(table).update({ name }).eq("id", id);
  if (error) throw error;
}

export async function deleteSettingsItem(table: SettingsTable, id: string) {
  const supabase = createClient();
  const { error } = await supabase.from(table).delete().eq("id", id);
  if (error) throw error;
}

export async function updateCategoryColor(id: string, color: string) {
  const supabase = createClient();
  const { error } = await supabase.from("categories").update({ color }).eq("id", id);
  if (error) throw error;
}

export async function fetchAllStatusHistory(): Promise<
  { id: string; organisation_id: string; status_id: string | null; changed_at: string }[]
> {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("status_history")
    .select("id, organisation_id, status_id, changed_at")
    .order("changed_at", { ascending: true });
  if (error) throw error;
  return (data ?? []) as {
    id: string;
    organisation_id: string;
    status_id: string | null;
    changed_at: string;
  }[];
}

// A status change counts as a "call attempt" if it's one of the
// "Call Attempted: X" statuses, or "Email Requested" (requesting an email
// during/after a call also counts as an attempt). Kept in sync with the
// database trigger in supabase/migrations (see 008_email_requested_call_attempt.sql).
export function isCallAttemptStatus(statusName: string | undefined | null): boolean {
  if (!statusName) return false;
  return statusName.startsWith("Call Attempted:") || statusName === "Email Requested";
}

// ============ Sources ============

export async function fetchAllSources(): Promise<Source[]> {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("sources")
    .select("*, source_source_types(source_type:source_types(id, name, sort_order))")
    .order("name");
  if (error) throw error;
  return (data ?? []).map((row: unknown) => {
    const r = row as Source & {
      source_source_types?: { source_type: SourceType }[];
    };
    return {
      ...r,
      source_types: (r.source_source_types ?? [])
        .map((j) => j.source_type)
        .filter(Boolean),
    };
  }) as Source[];
}

export async function createSource(fields: {
  name: string;
  website?: string | null;
  source_type_ids: string[];
}): Promise<string> {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("sources")
    .insert({ name: fields.name, website: fields.website ?? null })
    .select("id")
    .single();
  if (error) throw error;
  const sourceId = data.id as string;
  if (fields.source_type_ids.length > 0) {
    const { error: linkError } = await supabase.from("source_source_types").insert(
      fields.source_type_ids.map((source_type_id) => ({
        source_id: sourceId,
        source_type_id,
      }))
    );
    if (linkError) throw linkError;
  }
  return sourceId;
}

export async function updateSource(
  id: string,
  fields: { name?: string; website?: string | null }
) {
  const supabase = createClient();
  const { error } = await supabase.from("sources").update(fields).eq("id", id);
  if (error) throw error;
}

export async function setSourceTypes(sourceId: string, sourceTypeIds: string[]) {
  const supabase = createClient();
  const { error: deleteError } = await supabase
    .from("source_source_types")
    .delete()
    .eq("source_id", sourceId);
  if (deleteError) throw deleteError;
  if (sourceTypeIds.length > 0) {
    const { error: insertError } = await supabase.from("source_source_types").insert(
      sourceTypeIds.map((source_type_id) => ({ source_id: sourceId, source_type_id }))
    );
    if (insertError) throw insertError;
  }
}

export async function deleteSource(id: string) {
  const supabase = createClient();
  const { error } = await supabase.from("sources").delete().eq("id", id);
  if (error) throw error;
}

export function googleVoiceCallUrl(phoneNumber: string): string {
  const cleaned = phoneNumber.trim();
  return `https://voice.google.com/u/0/calls?a=nc,${encodeURIComponent(cleaned)}`;
}

// Opens a URL in a genuine new browser window (not just a new tab) by
// passing window features, which forces most browsers to pop out a window.
export function openInNewWindow(url: string) {
  const width = 1100;
  const height = 850;
  const left = window.screenX + Math.max(0, (window.outerWidth - width) / 2);
  const top = window.screenY + Math.max(0, (window.outerHeight - height) / 2);
  window.open(
    url,
    "_blank",
    `noopener,noreferrer,width=${width},height=${height},left=${left},top=${top}`
  );
}

// Builds the Google search URL for the "Research" button: searches for the
// named person's role at the organisation on LinkedIn.
export function researchSearchUrl(
  orgName: string,
  seniorityName: string,
  departmentName: string
): string {
  const q = `"${orgName}" "${seniorityName} ${departmentName}" LinkedIn`;
  return `https://www.google.com/search?q=${encodeURIComponent(q)}`;
}
