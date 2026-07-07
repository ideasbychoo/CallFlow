export type Status = {
  id: string;
  name: string;
  sort_order: number;
};

export type Department = {
  id: string;
  name: string;
  sort_order: number;
};

export type SeniorityLevel = {
  id: string;
  name: string;
  sort_order: number;
};

export type Category = {
  id: string;
  name: string;
  sort_order: number;
  color: string | null;
};

export type Country = {
  id: string;
  name: string;
  sort_order: number;
};

export type OfficeLocation = {
  id: string;
  organisation_id: string;
  location_name: string;
  phone_number: string | null;
  availability: string | null;
};

export type StaffMember = {
  id: string;
  organisation_id: string;
  department_id: string | null;
  seniority_id: string | null;
  full_name: string;
  job_title: string | null;
  email: string | null;
  direct_dial: string | null;
  linkedin: string | null;
  background_notes: string | null;
  availability_notes: string | null;
  conversation_notes: string | null;
};

export type StatusHistoryEntry = {
  id: string;
  organisation_id: string;
  status_id: string | null;
  changed_at: string;
  status?: Status | null;
};

export type Organisation = {
  id: string;
  name: string;
  category_id: string | null;
  country: string | null;
  similar_to_client: string | null;
  angle: string | null;
  notes: string | null;
  website: string | null;
  team_page: string | null;
  annual_report: string | null;
  impact_report: string | null;
  linkedin: string | null;
  beneficiaries: number | null;
  workers: number | null;
  status_id: string | null;
  date_spotted: string;
  call_attempts: number;
  last_interaction_at: string | null;
  created_at: string;
  updated_at: string;

  // joined/expanded on read
  category?: Category | null;
  office_locations?: OfficeLocation[];
  staff?: StaffMember[];
  status_history?: StatusHistoryEntry[];
};

export type SortField = "date_spotted" | "last_interaction_at" | "name";
export type SortDirection = "asc" | "desc";
