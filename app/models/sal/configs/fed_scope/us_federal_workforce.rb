class SAL::Configs::FedScope::USFederalWorkforce < SAL::Config

  def countable
    "employment_records"
  end

  def title
    "US Federal Workforce"
  end

  def klass
    FedScope::Employment
  end

  def default_metric
    "employee_count"
  end

  def allowable_modes
    [:advanced_search, :summary, :change_over_time, :dashboard]
  end

  def default_mode
    :summary
  end

  def default_dashboard
    :overview
  end

  def change_over_time_date_field
    :month
  end

  def periods
    @_periods ||= FedScope::Employment.distinct.order(month: :asc).pluck(:month)
  end

  SETTINGS = {
    metrics: {
      "employee_count" => {
        display_name: "Employee Count",
        metric_hsh: {
          field: "id",
          func: -> (col) { col.count(:unique) },
          alias: "employee_count",
          return_type: 'bigint'
        },
        result_options: {
          totalable: "Employment Records",
          display_transformation: -> (val) { ActiveSupport::NumberHelper.number_to_delimited(val.to_i) }
        }
      },
      "total_salaries" => {
        display_name: "Estimated Annual Salaries",
        metric_hsh: {
          field: "estimated_salary",
          func: -> (col) { col.sum },
          alias: "total_salaries"
        },
        result_options: {
          totalable: "Dollars",
          display_transformation: -> (val) { ActiveSupport::NumberHelper.number_to_currency(val, precision: 0) },
          chart_settings: {
            prefix: "$"
          }
        }
      }
    },
    displayable: {
      'month' => {
        display_name: "Month",
        show_by_default: true
      },
      "organization.name" => {
        display_name: "Organization",
        show_by_default: true
      },
      "agency.name" => {
        display_name: "Agency",
        show_by_default: true
      },
      "agency_type.name" => {
        display_name: "Agency Type",
        show_by_default: false
      },
      "location.name" => {
        display_name: "Location",
        show_by_default: false
      }
    },
    filterable: {
      "month" => {
        display_name: "Time Period",
        options: {
          min: Proc.new { FedScope::Employment.min_month },
          max: Proc.new { FedScope::Employment.max_month.end_of_month }
        }
      },
      "organization.id" => {
        display_name: "Organization",
        typeahead: true,
        path: :fed_scope_typeaheads_organizations_path,
        options: {
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "agency.id" => {
        display_name: "Agency",
        typeahead: true,
        path: :fed_scope_typeaheads_agencies_path,
        options: {
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "agency_type.id" => {
        display_name: "Agency Type",
        options: {
          collection: Proc.new { FedScope::AgencyType.order(:name) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "location.id" => {
        display_name: "Location",
        typeahead: true,
        path: :fed_scope_typeaheads_locations_path,
        options: {
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "location_type.id" => {
        display_name: "Location Type",
        options: {
          collection: Proc.new { FedScope::LocationType.order(:name) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "age_level.id" => {
        display_name: "Age Level",
        options: {
          collection: Proc.new { FedScope::AgeLevel.order(:code) },
          value_method: :id,
          text_method: :band,
          allow_multiple: true
        }
      },
      "education_level.id" => {
        display_name: "Education Level",
        options: {
          collection: Proc.new { FedScope::EducationLevel.order(:code) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "education_level_type.id" => {
        display_name: "Education Level Type",
        options: {
          collection: Proc.new { FedScope::EducationLevelType.order(:code) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "gsegrd.id" => {
        display_name: "General Schedule and Equivalent Grade",
        options: {
          collection: Proc.new { FedScope::GeneralScheduleAndEquivalentGrade.order(:code) },
          value_method: :id,
          text_method: :code,
          allow_multiple: true
        }
      },
      "length_of_service_band.id" => {
        display_name: "Length of Service",
        options: {
          collection: Proc.new { FedScope::LengthOfServiceBand.order(:code) },
          value_method: :id,
          text_method: :band,
          allow_multiple: true
        }
      },
      "occupation.id" => {
        display_name: "Occupation",
        typeahead: true,
        path: :fed_scope_typeaheads_occupations_path,
        options: {
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "occupation_family.id" => {
        display_name: "Occupation Family",
        typeahead: true,
        path: :fed_scope_typeaheads_occupation_families_path,
        options: {
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "occupation_type.id" => {
        display_name: "Occupation Type",
        typeahead: true,
        path: :fed_scope_typeaheads_occupation_types_path,
        options: {
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "occupation_category.id" => {
        display_name: "Occupation Category",
        options: {
          collection: Proc.new { FedScope::OccupationCategory.order(:name) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },      
      "pay_plan_grade.id" => {
        display_name: "Pay Plan Grade",
        typeahead: true,
        path: :fed_scope_typeaheads_pay_plan_grades_path,
        options: {
          value_method: :id,
          text_method: :code,
          allow_multiple: true
        }
      },
      "pay_plan.id" => {
        display_name: "Pay Plan",
        typeahead: true,
        path: :fed_scope_typeaheads_pay_plans_path,
        options: {
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "pay_plan_group.id" => {
        display_name: "Pay Plan Group",
        options: {
          collection: Proc.new { FedScope::PayPlanGroup.order(:code) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "pay_plan_type.id" => {
        display_name: "Pay Plan Type",
        options: {
          collection: Proc.new { FedScope::PayPlanType.order(:code) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "salary_band.id" => {
        display_name: "Salary Band",
        options: {
          collection: Proc.new { FedScope::SalaryBand.order(:id) },
          value_method: :id,
          text_method: :description,
          allow_multiple: true
        }
      },
      "stem_occupation.id" => {
        display_name: "STEM Occupation",
        typeahead: true,
        path: :fed_scope_typeaheads_stem_occupations_path,
        options: {
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },      
      "stem_occupation_type.id" => {
        display_name: "STEM Occupation Type",
        options: {
          collection: Proc.new { FedScope::STEMOccupationType.order(:code) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },      
      "stem_occupation_aggregate.id" => {
        display_name: "STEM Occupation Aggregate",
        options: {
          collection: Proc.new { FedScope::STEMOccupationAggregate.order(:code) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "supervisory_status.id" => {
        display_name: "Supervisory Status",
        options: {
          collection: Proc.new { FedScope::SupervisoryStatus.order(:code) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "supervisory_status_type.id" => {
        display_name: "Supervisory Status Type",
        options: {
          collection: Proc.new { FedScope::SupervisoryStatusType.order(:code) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "appointment_type.id" => {
        display_name: "Appointment Type",
        options: {
          collection: Proc.new { FedScope::AppointmentType.order(:code) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "appointment_type_type.id" => {
        display_name: "Appointment Type Type",
        options: {
          collection: Proc.new { FedScope::AppointmentTypeType.order(:code) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "work_schedule.id" => {
        display_name: "Work Schedule",
        options: {
          collection: Proc.new { FedScope::WorkSchedule.order(:code) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },
      "work_schedule_type.id" => {
        display_name: "Work Schedule Type",
        options: {
          collection: Proc.new { FedScope::WorkScheduleType.order(:code) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      },                
      "work_status.id" => {
        display_name: "Work Status",
        options: {
          collection: Proc.new { FedScope::WorkStatus.order(:code) },
          value_method: :id,
          text_method: :name,
          allow_multiple: true
        }
      }      
    },
    groupable: {
      "month" => {
        display_name: "Month",
        result_options: {
          display_transformation: -> (date) { date.to_formatted_s(:month_and_year) }
        }
      },
      "organization.id" => {
        display_name: "Organization",
        result_options: {
          display_transformation: :name
        }
      },
      "agency.id" => {
        display_name: "Agency",
        result_options: {
          display_transformation: :name
        }
      },
      "agency_type.id" => {
        display_name: "Agency Type",
        result_options: {
          display_transformation: :name
        }
      },
      "location.id" => {
        display_name: "Location",
        result_options: {
          display_transformation: :name
        }
      },
      "location_type.id" => {
        display_name: "Location Type",
        result_options: {
          display_transformation: :name
        }
      },
      "age_level.id" => {
        display_name: "Age Level",
        result_options: {
          display_transformation: :band
        }
      },
      "education_level.id" => {
        display_name: "Education Level",
        result_options: {
          display_transformation: :name
        }
      },
      "education_level_type.id" => {
        display_name: "Education Level Type",
        result_options: {
          display_transformation: :name
        }
      },
      "gsegrd.id" => {
        display_name: "General Schedule and Equivalent Grade",
        result_options: {
          display_transformation: :code
        }
      },
      "length_of_service_band.id" => {
        display_name: "Length of Service",
        result_options: {
          display_transformation: :band
        }
      },      
      "occupation.id" => {
        display_name: "Occupation",
        result_options: {
          display_transformation: :name
        }
      },
      "occupation_family.id" => {
        display_name: "Occupation Family",
        result_options: {
          display_transformation: :name
        }
      },
      "occupation_type.id" => {
        display_name: "Occupation Type",
        result_options: {
          display_transformation: :name
        }
      },
      "occupation_category.id" => {
        display_name: "Occupation Category",
        result_options: {
          display_transformation: :name
        }
      },
      "pay_plan_grade.id" => {
        display_name: "Pay Plan Grade",
        result_options: {
          display_transformation: :code
        }
      },
      "pay_plan.id" => {
        display_name: "Pay Plan",
        result_options: {
          display_transformation: :name
        }
      },
      "pay_plan_group.id" => {
        display_name: "Pay Plan Group",
        result_options: {
          display_transformation: :name
        }
      },
      "pay_plan_type.id" => {
        display_name: "Pay Plan Type",
        result_options: {
          display_transformation: :name
        }
      },
      "salary_band.id" => {
        display_name: "Salary Band",
        result_options: {
          display_transformation: :description
        }
      },
      "stem_occupation.id" => {
        display_name: "STEM Occupation",
        result_options: {
          display_transformation: :name
        }
      },
      "stem_occupation_type.id" => {
        display_name: "STEM Occupation Type",
        result_options: {
          display_transformation: :name
        }
      },
      "stem_occupation_aggregate.id" => {
        display_name: "STEM Occupation Aggregate",
        result_options: {
          display_transformation: :name
        }
      },
      "supervisory_status.id" => {
        display_name: "Supervisory Status",
        result_options: {
          display_transformation: :name
        }
      },     
      "supervisory_status_type.id" => {
        display_name: "Supervisory Status Type",
        result_options: {
          display_transformation: :name
        }
      },
      "appointment_type.id" => {
        display_name: "Appointment Type",
        result_options: {
          display_transformation: :name
        }
      },     
      "appointment_type_type.id" => {
        display_name: "Appointment Type Type",
        result_options: {
          display_transformation: :name
        }
      },
      "work_schedule.id" => {
        display_name: "Work Schedule",
        result_options: {
          display_transformation: :name
        }
      },     
      "work_schedule_type.id" => {
        display_name: "Work Schedule Type",
        result_options: {
          display_transformation: :name
        }
      },
      "work_status.id" => {
        display_name: "Work Status",
        result_options: {
          display_transformation: :name
        }
      }                    
    },
    dashboards: {
      "overview" => {
        title: "Overview",
        widgets: {
          "current_employee_count" => {
            title: -> (presenter) { "Employee Count as of #{presenter.builder.builder.query.send(:conditions)["month"].strftime("%B %Y") }" },
            query_args: {
              mode: :summary,
              metric: "employee_count",
              show_values_as: :no_calculation
            },
            condition_alterations: {
              "month" => -> (query) { query.send(:conditions)["month"]&.max&.beginning_of_month || FedScope::Employment.max_month  }
            },
            visualization_mode: :metric            
          },
          "current_annualized_salaries" => {
            title: -> (presenter) { "Total Annualized Salaries as of #{presenter.builder.builder.query.send(:conditions)["month"].strftime("%B %Y") }" },
            query_args: {
              mode: :summary,
              metric: "total_salaries",
              show_values_as: :no_calculation
            },
            condition_alterations: {
              "month" => -> (query) { query.send(:conditions)["month"]&.max&.beginning_of_month || FedScope::Employment.max_month  }
            },
            visualization_mode: :metric
          },
          "employee_count_over_time" => {
            title: "Employees Over Time",
            query_args: {
              mode: :summary,
              cols: "month",
              metric: "employee_count",
              show_values_as: :no_calculation
            },
            visualization_mode: :line_chart
          },
          "annualized_salaries_over_time" => {
            title: "Annualized Salaries Over Time",
            query_args: {
              mode: :summary,
              cols: "month",
              metric: "total_salaries",
              show_values_as: :no_calculation
            },
            visualization_mode: :line_chart
          },
          "top_agencies" => {
            title: -> (presenter) { "Largest Agencies as of #{presenter.builder.builder.query.send(:conditions)["month"].strftime("%B %Y") }" },
            query_args: {
              mode: :summary,
              rows: "agency.id",
              metric: "employee_count",
              show_values_as: :no_calculation,
              row_limit: 10
            },
            condition_alterations: {
              "month" => -> (query) { query.send(:conditions)["month"]&.max&.beginning_of_month || FedScope::Employment.max_month  }
            },
            visualization_mode: :table
          },
          "top_organizations" => {
            title: -> (presenter) { "Largest Organizations as of #{presenter.builder.builder.query.send(:conditions)["month"].strftime("%B %Y") }" },
            query_args: {
              mode: :summary,
              rows: "organization.id",
              metric: "employee_count",
              show_values_as: :no_calculation,
              row_limit: 10
            },
            condition_alterations: {
              "month" => -> (query) { query.send(:conditions)["month"]&.max&.beginning_of_month || FedScope::Employment.max_month  }
            },
            visualization_mode: :table
          },
          "top_locations" => {
            title: -> (presenter) { "Largest Locations as of #{presenter.builder.builder.query.send(:conditions)["month"].strftime("%B %Y") }" },
            query_args: {
              mode: :summary,
              rows: "location.id",
              metric: "employee_count",
              show_values_as: :no_calculation,
              row_limit: 10
            },
            condition_alterations: {
              "month" => -> (query) { query.send(:conditions)["month"]&.max&.beginning_of_month || FedScope::Employment.max_month  }
            },
            visualization_mode: :table
          },
          "top_occupation_families" => {
            title: -> (presenter) { "Largest Occupation Families as of #{presenter.builder.builder.query.send(:conditions)["month"].strftime("%B %Y") }" },
            query_args: {
              mode: :summary,
              rows: "occupation_family.id",
              metric: "employee_count",
              show_values_as: :no_calculation,
              row_limit: 10
            },
            condition_alterations: {
              "month" => -> (query) { query.send(:conditions)["month"]&.max&.beginning_of_month || FedScope::Employment.max_month  }
            },
            visualization_mode: :table
          },
          "employees_by_length_of_service" => {
            title: -> (presenter) { "Employees by Length of Service as of #{presenter.builder.builder.query.send(:conditions)["month"].strftime("%B %Y") }" },
            query_args: {
              mode: :summary,
              rows: "length_of_service_band.id",
              metric: "employee_count",
              order_by: ["substring(length_of_service_band_id, '^[0-9]+')::int", "ASC"],
              show_values_as: :no_calculation
            },
            condition_alterations: {
              "month" => -> (query) { query.send(:conditions)["month"]&.max&.beginning_of_month || FedScope::Employment.max_month  }
            },
            visualization_mode: :column_chart            
          },
          "employees_by_salary_band" => {
            title: -> (presenter) { "Employees by Salary Band as of #{presenter.builder.builder.query.send(:conditions)["month"].strftime("%B %Y") }" },
            query_args: {
              mode: :summary,
              rows: "salary_band.id",
              metric: "employee_count",
              order_by: ["substring(salary_band_id, '^[0-9]+')::int", "ASC"],
              show_values_as: :no_calculation
            },
            condition_alterations: {
              "month" => -> (query) { query.send(:conditions)["month"]&.max&.beginning_of_month || FedScope::Employment.max_month  }
            },
            visualization_mode: :column_chart            
          },
          "employees_by_age" => {
            title: -> (presenter) { "Employees by Age as of #{presenter.builder.builder.query.send(:conditions)["month"].strftime("%B %Y") }" },
            query_args: {
              mode: :summary,
              rows: "age_level.id",
              metric: "employee_count",
              order_by: ["substring(age_level_id, '^[0-9]+')::int", "ASC"],
              show_values_as: :no_calculation
            },
            condition_alterations: {
              "month" => -> (query) { query.send(:conditions)["month"]&.max&.beginning_of_month || FedScope::Employment.max_month  }
            },
            visualization_mode: :column_chart            
          }                                               
        }
      },
    }
  }.freeze

end