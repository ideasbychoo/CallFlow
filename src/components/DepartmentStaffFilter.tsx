"use client";

import type { Department } from "@/types";

export type DepartmentStaffFilterValue = {
  departmentId: string;
  min: string;
};

export const EMPTY_DEPARTMENT_STAFF_FILTER: DepartmentStaffFilterValue = {
  departmentId: "",
  min: "1",
};

// Lets Matt filter orgs down to ones with at least N staff members in a
// particular department (e.g. "at least 1 in Operations") so a run of calls
// can stay focused on talking to the same kind of role.
export default function DepartmentStaffFilter({
  departments,
  value,
  onChange,
}: {
  departments: Department[];
  value: DepartmentStaffFilterValue;
  onChange: (value: DepartmentStaffFilterValue) => void;
}) {
  const sortedDepartments = [...departments].sort(
    (a, b) => a.sort_order - b.sort_order
  );

  return (
    <div className="flex items-center gap-1.5 rounded border border-slate-300 bg-white px-3 py-1.5 text-sm text-slate-700">
      <span>Staff in dept:</span>
      <select
        value={value.departmentId}
        onChange={(e) =>
          onChange({ ...value, departmentId: e.target.value })
        }
        className="rounded border border-slate-200 px-1 py-0.5 text-slate-800 focus:border-slate-400 focus:outline-none"
      >
        <option value="">Any department</option>
        {sortedDepartments.map((d) => (
          <option key={d.id} value={d.id}>
            {d.name}
          </option>
        ))}
      </select>
      {value.departmentId && (
        <>
          <span className="text-slate-400">≥</span>
          <input
            type="number"
            min={1}
            value={value.min}
            onChange={(e) => onChange({ ...value, min: e.target.value })}
            placeholder="1"
            className="w-12 rounded border border-slate-200 px-1 py-0.5 text-slate-800 focus:border-slate-400 focus:outline-none"
          />
        </>
      )}
    </div>
  );
}

// Shared filter predicate used by Call List, Pipeline and Organisations pages.
export function matchesDepartmentStaffFilter(
  staffCount: number,
  filter: DepartmentStaffFilterValue
): boolean {
  if (!filter.departmentId) return true;
  const min = filter.min.trim() ? parseInt(filter.min, 10) : 1;
  return staffCount >= (Number.isNaN(min) ? 1 : min);
}

export function countStaffInDepartment(
  staff: { department_id: string | null; full_name?: string | null }[] | undefined,
  departmentId: string
): number {
  return (staff ?? []).filter(
    (p) => p.department_id === departmentId && isIdentifiedStaffMember(p)
  ).length;
}

// A staff row created via "+ Add person" but never actually filled in
// shouldn't count as an "identified" staff member for filtering purposes.
export function isIdentifiedStaffMember(person: { full_name?: string | null }): boolean {
  const name = person.full_name?.trim().toLowerCase() ?? "";
  return name !== "" && name !== "new person";
}
