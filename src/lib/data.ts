import { createClient } from "@/lib/supabase/client";
import type {
  Organisation,
  Status,
  Department,
  SeniorityLevel,
  Category,
} from "@/types";

const ORG_SELECT = `
  *,
  category:categories(id, name, sort_order),
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
}> {
  const supabase = createClient();
  const [statuses, departments, seniorityLevels, categories] =
    await Promise.all([
      supabase.from("statuses").select("*").order("sort_order"),
      supabase.from("departments").select("*").order("sort_order"),
      supabase.from("seniority_levels").select("*").order("sort_order"),
      supabase.from("categories").select("*").order("sort_order"),
    ]);

  return {
    statuses: (statuses.data ?? []) as Status[],
    departments: (departments.data ?? []) as Department[],
    seniorityLevels: (seniorityLevels.data ?? []) as SeniorityLevel[],
    categories: (categories.data ?? []) as Category[],
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

export async function upsertStaffMember(fields: Record<string, unknown>) {
  const supabase = createClient();
  const { error } = await supabase.from("staff").upsert(fields);
  if (error) throw error;
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
  | "categories";

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

export function googleVoiceCallUrl(phoneNumber: string): string {
  const cleaned = phoneNumber.trim();
  return `https://voice.google.com/u/0/calls?a=nc,${encodeURIComponent(cleaned)}`;
}
