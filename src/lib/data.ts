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
  ReportGroup,
  StaffMember,
  EmailTemplate,
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
  reportGroups: ReportGroup[];
}> {
  const supabase = createClient();
  const [statuses, departments, seniorityLevels, categories, countries, sourceTypes, segments, reportGroupsRaw] =
    await Promise.all([
      supabase.from("statuses").select("*").order("sort_order"),
      supabase.from("departments").select("*").order("sort_order"),
      supabase.from("seniority_levels").select("*").order("sort_order"),
      supabase.from("categories").select("*").order("sort_order"),
      supabase.from("countries").select("*").order("sort_order"),
      supabase.from("source_types").select("*").order("sort_order"),
      supabase.from("segments").select("*").order("sort_order"),
      supabase
        .from("report_groups")
        .select("*, report_group_statuses(status:statuses(*))")
        .order("sort_order"),
    ]);

  const reportGroups = (reportGroupsRaw.data ?? []).map((row: unknown) => {
    const r = row as ReportGroup & { report_group_statuses?: { status: Status }[] };
    return {
      ...r,
      statuses: (r.report_group_statuses ?? []).map((j) => j.status).filter(Boolean),
    };
  }) as ReportGroup[];

  return {
    statuses: (statuses.data ?? []) as Status[],
    departments: (departments.data ?? []) as Department[],
    seniorityLevels: (seniorityLevels.data ?? []) as SeniorityLevel[],
    categories: (categories.data ?? []) as Category[],
    countries: (countries.data ?? []) as Country[],
    sourceTypes: (sourceTypes.data ?? []) as SourceType[],
    segments: (segments.data ?? []) as Segment[],
    reportGroups,
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

// Returns a label identifying the logged-in person, for created_by tracking.
// Falls back to a generic label if the session can't be read for some reason.
async function getCurrentUserLabel(): Promise<string> {
  const supabase = createClient();
  const { data } = await supabase.auth.getUser();
  return data.user?.email ?? "unknown-user";
}

export async function createOrganisation(
  fields: Partial<Organisation>
): Promise<string> {
  const supabase = createClient();
  const created_by = fields.created_by ?? (await getCurrentUserLabel());
  const { data, error } = await supabase
    .from("organisations")
    .insert({ ...fields, created_by })
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
  const created_by = (fields.created_by as string | undefined) ?? (await getCurrentUserLabel());
  const { data, error } = await supabase
    .from("staff")
    .insert({ ...fields, created_by })
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

// Persists a new drag-and-drop order for a settings list: assigns sequential
// sort_order values (1, 2, 3...) matching the given id order.
export async function reorderSettingsItems(table: SettingsTable, orderedIds: string[]) {
  const supabase = createClient();
  await Promise.all(
    orderedIds.map((id, index) =>
      supabase.from(table).update({ sort_order: index + 1 }).eq("id", id)
    )
  );
}

export async function setStatusCountsAsCallAttempt(id: string, value: boolean) {
  const supabase = createClient();
  const { error } = await supabase
    .from("statuses")
    .update({ counts_as_call_attempt: value })
    .eq("id", id);
  if (error) throw error;
}

// ============ Report Groups (configurable Reporting summary columns) ============

export async function createReportGroup(name: string, statusIds: string[]): Promise<string> {
  const supabase = createClient();
  const { data: maxRow } = await supabase
    .from("report_groups")
    .select("sort_order")
    .order("sort_order", { ascending: false })
    .limit(1)
    .maybeSingle();
  const nextOrder = (maxRow?.sort_order ?? 0) + 1;

  const { data, error } = await supabase
    .from("report_groups")
    .insert({ name, sort_order: nextOrder })
    .select("id")
    .single();
  if (error) throw error;

  if (statusIds.length > 0) {
    const { error: linkError } = await supabase
      .from("report_group_statuses")
      .insert(statusIds.map((status_id) => ({ report_group_id: data.id, status_id })));
    if (linkError) throw linkError;
  }
  return data.id as string;
}

export async function renameReportGroup(id: string, name: string) {
  const supabase = createClient();
  const { error } = await supabase.from("report_groups").update({ name }).eq("id", id);
  if (error) throw error;
}

export async function setReportGroupStatuses(reportGroupId: string, statusIds: string[]) {
  const supabase = createClient();
  const { error: deleteError } = await supabase
    .from("report_group_statuses")
    .delete()
    .eq("report_group_id", reportGroupId);
  if (deleteError) throw deleteError;
  if (statusIds.length > 0) {
    const { error: insertError } = await supabase
      .from("report_group_statuses")
      .insert(statusIds.map((status_id) => ({ report_group_id: reportGroupId, status_id })));
    if (insertError) throw insertError;
  }
}

export async function deleteReportGroup(id: string) {
  const supabase = createClient();
  const { error } = await supabase.from("report_groups").delete().eq("id", id);
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

// ============ Email Templates ============

export async function fetchAllEmailTemplates(): Promise<EmailTemplate[]> {
  const supabase = createClient();
  const { data, error } = await supabase.from("email_templates").select("*").order("title");
  if (error) throw error;
  return (data ?? []) as EmailTemplate[];
}

export async function createEmailTemplate(fields: {
  title: string;
  subject?: string;
  body?: string;
}): Promise<string> {
  const supabase = createClient();
  const { data, error } = await supabase
    .from("email_templates")
    .insert(fields)
    .select("id")
    .single();
  if (error) throw error;
  return data.id as string;
}

export async function updateEmailTemplate(
  id: string,
  fields: Partial<Pick<EmailTemplate, "title" | "subject" | "body">>
) {
  const supabase = createClient();
  const { error } = await supabase.from("email_templates").update(fields).eq("id", id);
  if (error) throw error;
}

export async function deleteEmailTemplate(id: string) {
  const supabase = createClient();
  const { error } = await supabase.from("email_templates").delete().eq("id", id);
  if (error) throw error;
}

// The set of mail merge tags available when writing an Email Template body,
// looked up from the Organisation and Staff record the email is being sent
// about/to.
export const MAIL_MERGE_TAGS: { tag: string; label: string }[] = [
  { tag: "{{org.name}}", label: "Organisation name" },
  { tag: "{{org.category}}", label: "Organisation category" },
  { tag: "{{org.segment}}", label: "Organisation segment" },
  { tag: "{{org.country}}", label: "Organisation country" },
  { tag: "{{org.website}}", label: "Organisation website" },
  { tag: "{{staff.full_name}}", label: "Contact full name" },
  { tag: "{{staff.first_name}}", label: "Contact first name" },
  { tag: "{{staff.job_title}}", label: "Contact job title" },
  { tag: "{{staff.department}}", label: "Contact department" },
  { tag: "{{staff.seniority}}", label: "Contact seniority" },
];

export function resolveMergeTags(
  text: string,
  org: Organisation,
  staff: StaffMember,
  departmentName?: string,
  seniorityName?: string
): string {
  const firstName = staff.full_name?.split(" ")[0] ?? "";
  const values: Record<string, string> = {
    "{{org.name}}": org.name ?? "",
    "{{org.category}}": org.category?.name ?? "",
    "{{org.segment}}": org.segment?.name ?? "",
    "{{org.country}}": org.country ?? "",
    "{{org.website}}": org.website ?? "",
    "{{staff.full_name}}": staff.full_name ?? "",
    "{{staff.first_name}}": firstName,
    "{{staff.job_title}}": staff.job_title ?? "",
    "{{staff.department}}": departmentName ?? "",
    "{{staff.seniority}}": seniorityName ?? "",
  };
  let result = text;
  for (const [tag, value] of Object.entries(values)) {
    result = result.split(tag).join(value);
  }
  return result;
}

// Builds a Gmail compose URL, pre-filled with the recipient, subject, and
// body. Opens Gmail's own compose window (does not send automatically).
export function gmailComposeUrl(to: string, subject: string, body: string): string {
  const params = new URLSearchParams({ view: "cm", fs: "1", to, su: subject, body });
  return `https://mail.google.com/mail/?${params.toString()}`;
}

export function googleVoiceCallUrl(phoneNumber: string): string {
  const cleaned = phoneNumber.trim();
  return `https://voice.google.com/u/0/calls?a=nc,${encodeURIComponent(cleaned)}`;
}

// Opens a URL in a genuine new browser window (not just a new tab) by
// passing window features, which forces most browsers to pop out a window.
export function openInNewWindow(url: string) {
  // window.open() can't reliably force a real, fully-chromed browser window in
  // modern Chrome: with no size features it opens a tab, and with any size
  // feature it opens a stripped-down popup with no tab strip. The one thing
  // that *does* reliably open a normal new window (the same as a user
  // Shift-clicking a link) is a native anchor click with shiftKey set, so we
  // build one temporarily and dispatch that.
  const anchor = document.createElement("a");
  anchor.href = url;
  anchor.target = "_blank";
  anchor.rel = "noopener noreferrer";
  anchor.style.display = "none";
  document.body.appendChild(anchor);
  anchor.dispatchEvent(
    new MouseEvent("click", {
      bubbles: true,
      cancelable: true,
      view: window,
      shiftKey: true,
    })
  );
  document.body.removeChild(anchor);
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
