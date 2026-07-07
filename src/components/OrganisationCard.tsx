"use client";

import { useState } from "react";
import { format, formatDistanceToNow } from "date-fns";
import { EditableText } from "./EditableField";
import StatusDropdown from "./StatusDropdown";
import CategoryChip from "./CategoryChip";
import CountryFlag from "./CountryFlag";
import type {
  Organisation,
  Status,
  Department,
  SeniorityLevel,
  Category,
  Country,
  StaffMember,
} from "@/types";
import {
  updateOrganisation,
  upsertStaffMember,
  deleteStaffMember,
  upsertOfficeLocation,
  deleteOfficeLocation,
  deleteOrganisation,
  googleVoiceCallUrl,
} from "@/lib/data";

export default function OrganisationCard({
  org,
  statuses,
  departments,
  seniorityLevels,
  categories,
  countries,
  defaultExpanded = false,
  onChanged,
}: {
  org: Organisation;
  statuses: Status[];
  departments: Department[];
  seniorityLevels: SeniorityLevel[];
  categories: Category[];
  countries: Country[];
  defaultExpanded?: boolean;
  onChanged: () => void;
}) {
  const [expanded, setExpanded] = useState(defaultExpanded);
  const [showHistory, setShowHistory] = useState(false);

  async function save(fields: Partial<Organisation>) {
    await updateOrganisation(org.id, fields);
    onChanged();
  }

  const staffByCell = new Map<string, StaffMember[]>();
  const unassignedStaff: StaffMember[] = [];
  for (const person of org.staff ?? []) {
    if (!person.department_id || !person.seniority_id) {
      unassignedStaff.push(person);
      continue;
    }
    const key = `${person.department_id}::${person.seniority_id}`;
    if (!staffByCell.has(key)) staffByCell.set(key, []);
    staffByCell.get(key)!.push(person);
  }

  const sortedDepartments = [...departments].sort(
    (a, b) => a.sort_order - b.sort_order
  );
  const sortedSeniority = [...seniorityLevels].sort(
    (a, b) => a.sort_order - b.sort_order
  );

  async function addPerson(departmentId: string, seniorityId: string) {
    await upsertStaffMember({
      organisation_id: org.id,
      department_id: departmentId,
      seniority_id: seniorityId,
      full_name: "New person",
    });
    onChanged();
  }

  async function addLocation() {
    await upsertOfficeLocation({
      organisation_id: org.id,
      location_name: "New location",
    });
    onChanged();
  }

  const sortedCategories = [...categories].sort((a, b) => a.name.localeCompare(b.name));
  const selectedCategory = categories.find((c) => c.id === org.category_id) ?? null;

  return (
    <div
      className="mb-4 rounded-xl border border-slate-200 bg-white shadow-sm"
      style={
        selectedCategory?.color
          ? { borderLeft: `4px solid ${selectedCategory.color}` }
          : undefined
      }
    >
      {/* Header row - always visible */}
      <div className="flex items-start justify-between gap-4 p-5">
        <button
          onClick={() => setExpanded((v) => !v)}
          className="mt-1 shrink-0 text-slate-400 hover:text-slate-700"
          aria-label={expanded ? "Collapse" : "Expand"}
        >
          {expanded ? "▾" : "▸"}
        </button>

        <div className="flex-1">
          <EditableText
            value={org.name}
            onSave={(v) => save({ name: v })}
            className="w-full rounded border border-transparent bg-transparent text-xl font-semibold text-slate-800 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
          />
          <div className="mt-1 flex flex-wrap items-center gap-2 text-sm text-slate-600">
            {selectedCategory && (
              <CategoryChip name={selectedCategory.name} color={selectedCategory.color} />
            )}
            <select
              value={org.category_id ?? ""}
              onChange={(e) => save({ category_id: e.target.value || null })}
              className="rounded border border-transparent bg-transparent text-sm text-slate-600 hover:border-slate-200 focus:border-slate-400 focus:outline-none"
            >
              <option value="">No category</option>
              {sortedCategories.map((c) => (
                <option key={c.id} value={c.id}>
                  {c.name}
                </option>
              ))}
            </select>
            <span className="font-medium">· Similar to</span>
            <EditableText
              value={org.similar_to_client}
              onSave={(v) => save({ similar_to_client: v })}
              placeholder="client name"
              className="w-40 rounded border border-transparent bg-transparent text-sm hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
            />
          </div>
          <div className="mt-1 flex items-start gap-1 text-sm">
            <span className="font-medium text-slate-700">Angle:</span>
            <EditableText
              value={org.angle}
              onSave={(v) => save({ angle: v })}
              placeholder="Why Makerble is a good fit"
              multiline
              className="w-full flex-1 rounded border border-transparent bg-transparent text-sm text-slate-600 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
            />
          </div>
        </div>

        <div className="flex shrink-0 flex-col items-end gap-2">
          <StatusDropdown
            statuses={statuses}
            value={org.status_id}
            onChange={(statusId) => save({ status_id: statusId })}
          />
          <div className="text-right text-xs leading-relaxed text-slate-500">
            <div className="flex items-center justify-end gap-1">
              <CountryFlag country={org.country} />
              <select
                value={org.country ?? ""}
                onChange={(e) => save({ country: e.target.value || null })}
                className="rounded border border-transparent bg-transparent text-right text-xs text-slate-500 hover:border-slate-200 focus:border-slate-400 focus:outline-none"
              >
                <option value="">No country</option>
                {[...countries]
                  .sort((a, b) => a.name.localeCompare(b.name))
                  .map((c) => (
                    <option key={c.id} value={c.name}>
                      {c.name}
                    </option>
                  ))}
              </select>
            </div>
            <div>
              Spotted:{" "}
              <EditableText
                value={org.date_spotted}
                onSave={(v) => save({ date_spotted: v })}
                className="inline w-24 rounded border border-transparent bg-transparent text-right text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
              />
            </div>
            <div>
              Recent interaction:{" "}
              {org.last_interaction_at
                ? formatDistanceToNow(new Date(org.last_interaction_at), {
                    addSuffix: true,
                  })
                : "—"}
            </div>
            <button
              onClick={() => setShowHistory((v) => !v)}
              className="underline decoration-dotted hover:text-slate-700"
            >
              Call attempts: {org.call_attempts}
            </button>
          </div>
        </div>
      </div>

      {showHistory && (
        <div className="border-t border-slate-100 bg-slate-50 px-5 py-3 text-xs text-slate-600">
          <div className="mb-1 font-medium text-slate-700">History</div>
          {(org.status_history ?? [])
            .slice()
            .sort(
              (a, b) =>
                new Date(b.changed_at).getTime() -
                new Date(a.changed_at).getTime()
            )
            .map((h) => {
              const statusName =
                statuses.find((s) => s.id === h.status_id)?.name ?? "—";
              return (
                <div key={h.id}>
                  {statusName} — {format(new Date(h.changed_at), "d MMM, HH:mm")}
                </div>
              );
            })}
          {(org.status_history ?? []).length === 0 && <div>No history yet.</div>}
        </div>
      )}

      {!expanded ? null : (
        <div className="border-t border-slate-100 px-5 pb-5 pt-4">
          <div className="flex flex-col gap-6 lg:flex-row">
            {/* Staff grid */}
            <div className="flex-1 overflow-x-auto">
              <table className="w-full border-collapse text-sm">
                <thead>
                  <tr>
                    <th className="w-40 border-b border-slate-200 pb-2 text-left font-medium text-slate-500"></th>
                    {sortedSeniority.map((s) => (
                      <th
                        key={s.id}
                        className="border-b border-slate-200 pb-2 text-left font-medium text-slate-700"
                      >
                        {s.name}
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {sortedDepartments.map((dept) => (
                    <tr key={dept.id} className="align-top">
                      <td className="border-b border-slate-100 py-3 pr-3 font-medium text-slate-700">
                        {dept.name}
                      </td>
                      {sortedSeniority.map((sen) => {
                        const key = `${dept.id}::${sen.id}`;
                        const people = staffByCell.get(key) ?? [];
                        return (
                          <td
                            key={sen.id}
                            className="border-b border-slate-100 py-3 pr-3"
                          >
                            <div className="space-y-3">
                              {people.map((p) => (
                                <StaffPersonEditor
                                  key={p.id}
                                  person={p}
                                  onChanged={onChanged}
                                />
                              ))}
                            </div>
                            <button
                              onClick={() => addPerson(dept.id, sen.id)}
                              className="mt-1 text-xs text-slate-400 hover:text-slate-700"
                            >
                              + Add person
                            </button>
                          </td>
                        );
                      })}
                    </tr>
                  ))}
                </tbody>
              </table>

              {unassignedStaff.length > 0 && (
                <div className="mt-4">
                  <div className="mb-2 text-xs font-medium uppercase tracking-wide text-slate-400">
                    Other contacts
                  </div>
                  <div className="grid gap-3 sm:grid-cols-2">
                    {unassignedStaff.map((p) => (
                      <StaffPersonEditor
                        key={p.id}
                        person={p}
                        onChanged={onChanged}
                      />
                    ))}
                  </div>
                </div>
              )}
            </div>

            {/* Right column: locations + links */}
            <div className="w-full shrink-0 space-y-4 text-sm lg:w-64">
              <div>
                <div className="mb-1 flex items-center justify-between">
                  <span className="font-medium text-slate-700">
                    Office locations
                  </span>
                  <button
                    onClick={addLocation}
                    className="text-xs text-slate-400 hover:text-slate-700"
                  >
                    + Add
                  </button>
                </div>
                <div className="space-y-2">
                  {(org.office_locations ?? []).map((loc) => (
                    <div
                      key={loc.id}
                      className="rounded border border-slate-100 p-2"
                    >
                      <EditableText
                        value={loc.location_name}
                        onSave={(v) =>
                          upsertOfficeLocation({
                            id: loc.id,
                            organisation_id: org.id,
                            location_name: v,
                            phone_number: loc.phone_number,
                          }).then(onChanged)
                        }
                        className="w-full rounded border border-transparent bg-transparent text-xs font-medium text-slate-600 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
                      />
                      <div className="mt-1 flex items-center gap-2">
                        {loc.phone_number && (
                          <a
                            href={googleVoiceCallUrl(loc.phone_number)}
                            target="_blank"
                            rel="noreferrer"
                            className="text-blue-600 hover:underline"
                          >
                            {loc.phone_number}
                          </a>
                        )}
                        <EditableText
                          value={loc.phone_number}
                          onSave={(v) =>
                            upsertOfficeLocation({
                              id: loc.id,
                              organisation_id: org.id,
                              location_name: loc.location_name,
                              phone_number: v,
                              availability: loc.availability,
                            }).then(onChanged)
                          }
                          placeholder="Phone number"
                          className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
                        />
                        <button
                          onClick={() =>
                            deleteOfficeLocation(loc.id).then(onChanged)
                          }
                          className="ml-auto text-xs text-slate-300 hover:text-red-500"
                        >
                          ✕
                        </button>
                      </div>
                      <EditableText
                        value={loc.availability}
                        onSave={(v) =>
                          upsertOfficeLocation({
                            id: loc.id,
                            organisation_id: org.id,
                            location_name: loc.location_name,
                            phone_number: loc.phone_number,
                            availability: v,
                          }).then(onChanged)
                        }
                        placeholder="e.g. Mon–Fri 9am–1pm"
                        className="mt-1 w-full rounded border border-transparent bg-transparent text-xs text-slate-500 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
                      />
                    </div>
                  ))}
                </div>
              </div>

              <LinkField
                label="Website"
                value={org.website}
                onSave={(v) => save({ website: v })}
              />
              <LinkField
                label="Organisation LinkedIn"
                value={org.linkedin}
                onSave={(v) => save({ linkedin: v })}
              />
              <LinkField
                label="Team page"
                value={org.team_page}
                onSave={(v) => save({ team_page: v })}
              />
              <LinkField
                label="Annual report"
                value={org.annual_report}
                onSave={(v) => save({ annual_report: v })}
              />
              <LinkField
                label="Impact report"
                value={org.impact_report}
                onSave={(v) => save({ impact_report: v })}
              />

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <div className="font-medium text-slate-700">Beneficiaries</div>
                  <EditableText
                    value={org.beneficiaries?.toString() ?? ""}
                    onSave={(v) =>
                      save({ beneficiaries: v.trim() ? Number(v) : null })
                    }
                    placeholder="e.g. 5000"
                    className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
                  />
                </div>
                <div>
                  <div className="font-medium text-slate-700">Workers</div>
                  <EditableText
                    value={org.workers?.toString() ?? ""}
                    onSave={(v) =>
                      save({ workers: v.trim() ? Number(v) : null })
                    }
                    placeholder="staff/volunteers"
                    className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
                  />
                </div>
              </div>

              <div>
                <div className="mb-1 font-medium text-slate-700">Notes</div>
                <EditableText
                  value={org.notes}
                  onSave={(v) => save({ notes: v })}
                  multiline
                  placeholder="Research / call notes"
                  className="w-full rounded border border-slate-200 bg-slate-50 px-2 py-1 text-xs hover:border-slate-300 focus:border-slate-400 focus:bg-white focus:outline-none"
                />
              </div>

              <button
                onClick={() => {
                  if (confirm(`Delete ${org.name}? This can't be undone.`)) {
                    deleteOrganisation(org.id).then(onChanged);
                  }
                }}
                className="text-xs text-slate-300 hover:text-red-500"
              >
                Delete organisation
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

function LinkField({
  label,
  value,
  onSave,
}: {
  label: string;
  value: string | null | undefined;
  onSave: (v: string) => void;
}) {
  return (
    <div>
      <div className="font-medium text-slate-700">{label}</div>
      <div className="flex items-center gap-2">
        {value && (
          <a
            href={value}
            target="_blank"
            rel="noreferrer"
            className="truncate text-xs text-blue-600 hover:underline"
          >
            {value}
          </a>
        )}
      </div>
      <EditableText
        value={value}
        onSave={onSave}
        placeholder="https://…"
        className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
    </div>
  );
}

function StaffPersonEditor({
  person,
  onChanged,
}: {
  person: StaffMember;
  onChanged: () => void;
}) {
  async function update(fields: Partial<StaffMember>) {
    await upsertStaffMember({ ...person, ...fields, id: person.id });
    onChanged();
  }

  return (
    <div className="rounded border border-slate-100 p-2">
      <EditableText
        value={person.full_name}
        onSave={(v) => update({ full_name: v })}
        className="w-full rounded border border-transparent bg-transparent text-sm font-medium text-slate-800 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <EditableText
        value={person.job_title}
        onSave={(v) => update({ job_title: v })}
        placeholder="Job title"
        className="w-full rounded border border-transparent bg-transparent text-xs italic text-slate-500 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <div className="flex flex-wrap gap-x-2 text-xs">
        {person.email && (
          <a
            href={`mailto:${person.email}`}
            className="text-blue-600 hover:underline"
          >
            {person.email}
          </a>
        )}
        {person.linkedin && (
          <a
            href={person.linkedin}
            target="_blank"
            rel="noreferrer"
            className="text-blue-600 hover:underline"
          >
            LinkedIn
          </a>
        )}
        {person.direct_dial && (
          <a
            href={googleVoiceCallUrl(person.direct_dial)}
            target="_blank"
            rel="noreferrer"
            className="text-blue-600 hover:underline"
          >
            {person.direct_dial}
          </a>
        )}
      </div>
      <EditableText
        value={person.email}
        onSave={(v) => update({ email: v })}
        placeholder="Email"
        className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <EditableText
        value={person.linkedin}
        onSave={(v) => update({ linkedin: v })}
        placeholder="LinkedIn URL"
        className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <EditableText
        value={person.direct_dial}
        onSave={(v) => update({ direct_dial: v })}
        placeholder="Direct dial"
        className="w-full rounded border border-transparent bg-transparent text-xs hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <EditableText
        value={person.availability_notes}
        onSave={(v) => update({ availability_notes: v })}
        placeholder="Availability notes"
        className="w-full rounded border border-transparent bg-transparent text-xs text-slate-500 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <EditableText
        value={person.background_notes}
        onSave={(v) => update({ background_notes: v })}
        placeholder="Background notes"
        multiline
        className="w-full rounded border border-transparent bg-transparent text-xs text-slate-500 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <EditableText
        value={person.conversation_notes}
        onSave={(v) => update({ conversation_notes: v })}
        placeholder="Conversation notes"
        multiline
        className="w-full rounded border border-transparent bg-transparent text-xs text-slate-500 hover:border-slate-200 focus:border-slate-400 focus:bg-white focus:outline-none"
      />
      <button
        onClick={() => deleteStaffMember(person.id).then(onChanged)}
        className="mt-1 text-xs text-slate-300 hover:text-red-500"
      >
        Remove
      </button>
    </div>
  );
}
