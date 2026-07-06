-- ============================================
-- SurveyHero001 INIT - regenerated from UAT 2026-06-02 10:45:23
-- ============================================
USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddIntegration]
		@IntegrationName = N'SurveyHero001',
		@IntegrationDisplayName = N'SurveyHero'

SELECT	'Return Value' = @return_value

GO

UPDATE [core].[Integrations] SET
[APIEndpointDetail] = '{
  "api_info": {
    "source": "surveyhero",
    "version": "v1",
    "base_url": "https://api.surveyhero.com"
  },
  "pagination": {
    "pagination_flag_key": "has_more",
    "pagination_value_key": "page"
  },
  "endpoints": {
    "surveys": {
      "endpoint": "surveys",
      "id_column": "survey_id",
      "unique_identifier": "survey_id",
      "unravel_properties": {
        "surveys": [
          "explode"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [],
      "rename_cols": {}
    },
    "surveys_details": {
      "endpoint": "surveys/{survey_id}",
      "id_column": "survey_id",
      "unique_identifier": "survey_id",
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [],
      "rename_cols": {
        "settings.is_anonymous": "settings_is_anonymous"
      }
    },
    "elements": {
      "endpoint": "surveys/{survey_id}/elements",
      "id_column": "element_id",
      "unique_identifier": "element_id",
      "unravel_properties": {
        "elements": [
          "explode"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {
        "elements_element_id": "element_id",
        "elements_type": "element_type"
      }
    },
    "elements_questions": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": "element_id",
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "elements_element_id",
          "element_id"
        ]
      ],
      "rename_cols": {
        "type": "question_type",
        "text": "question_text",
        "description": "description_text",
        "settings.is_required": "settings_is_required"
      }
    },
    "elements_codes": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": "element_id",
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "code": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "elements_element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_texts": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": "element_id",
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "text": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "elements_element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_images": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": "element_id",
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "image": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "elements_element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_separators": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": "element_id",
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "separator": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "elements_element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_questions_choicelists": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "choice_list": [
          "unnest"
        ],
        "settings": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {
        "allows_multiple_choices": "settings_allows_multiple_choices",
        "min_number_of_choices": "settings_min_number_of_choices",
        "max_number_of_choices": "settings_max_number_of_choices"
      }
    },
    "elements_questions_choicelists_choices": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "element_id",
        "choice_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "choice_list": [
          "unnest"
        ],
        "choices": [
          "explode",
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "elements_element_id",
          "element_id"
        ]
      ],
      "rename_cols": {
        "id": "choice_id"
      }
    },
    "elements_questions_choicetables": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "choice_table": [
          "unnest"
        ],
        "settings": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {
        "allows_multiple_choices_per_row": "settings_allows_multiple_choices_per_row"
      }
    },
    "elements_questions_choicetables_rows": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id",
        "row_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "choice_table": [
          "unnest"
        ],
        "rows": [
          "explode",
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_questions_choicetables_choices": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id",
        "choice_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "choice_table": [
          "unnest"
        ],
        "choices": [
          "explode",
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_questions_fileuploads": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "file_upload": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_questions_fileuploads_acceptedfiletypes": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "file_upload": [
          "unnest"
        ],
        "accepted_file_types": [
          "explode"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {
        "accepted_file_types": "file_type"
      }
    },
    "elements_questions_rankings": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "ranking": [
          "unnest"
        ],
        "settings": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {
        "allows_not_applicable": "settings_allows_not_applicable",
        "not_applicable_label": "settings_not_applicable_label"
      }
    },
    "elements_questions_rankings_choices": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "ranking": [
          "unnest"
        ],
        "choices": [
          "explode",
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_questions_ratingscales": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "rating_scale": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {
        "left.label": "left_label",
        "left.value": "left_value",
        "right.label": "right_label",
        "right.value": "right_value"
      }
    },
    "elements_questions_imagechoicelists": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "image_choice_list": [
          "unnest"
        ],
        "settings": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {
        "allows_multiple_choices": "settings_allows_multiple_choices",
        "min_number_of_choices": "settings_min_number_of_choices",
        "max_number_of_choices": "settings_max_number_of_choices"
      }
    },
    "elements_questions_imagechoicelists_choices": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id",
        "choice_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "image_choice_list": [
          "unnest"
        ],
        "choices": [
          "explode",
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_questions_inputs": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "input": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_questions_inputlists": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "input_list": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_questions_inputlists_inputs": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "input_list": [
          "unnest"
        ],
        "inputs": [
          "explode",
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_questions_inputtables": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "input_table": [
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_questions_inputtables_rows": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id",
        "row_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "input_table": [
          "unnest"
        ],
        "rows": [
          "explode",
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "elements_questions_inputtables_columns": {
      "endpoint": "surveys/{survey_id}/elements",
      "unique_identifier": [
        "survey_id",
        "element_id",
        "column_id"
      ],
      "unravel_properties": {
        "elements": [
          "explode"
        ],
        "question": [
          "unnest"
        ],
        "input_table": [
          "unnest"
        ],
        "columns": [
          "explode",
          "unnest"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ],
        [
          "element_id",
          "element_id"
        ]
      ],
      "rename_cols": {}
    },
    "responses": {
      "endpoint": "surveys/{survey_id}/responses",
      "unique_identifier": [
        "response_id"
      ],
      "unravel_properties": {
        "responses": [
          "explode"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {
        "code": "language_code",
        "name": "language_name"
      }
    },
    "responses_answers": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "answer_element_id"
      ],
      "unravel_properties": {
        "answers": [
          "explode"
        ]
      },
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {
        "code": "language_code",
        "name": "language_name",
        "element_id": "answer_element_id",
        "question_text": "answer_question_text",
        "type": "answer_type"
      }
    },
    "responses_answers_dates": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "element_id"
      ],
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {
        "date": "value"
      }
    },
    "responses_answers_texts": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "element_id"
      ],
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {
        "text": "value"
      }
    },
    "responses_answers_numbers": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "element_id"
      ],
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {
        "number": "value"
      }
    },
    "responses_answers_files": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "element_id"
      ],
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {}
    },
    "responses_answers_choices": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "element_id",
        "choice_id"
      ],
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {}
    },
    "responses_answers_choicetables": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "element_id",
        "row_id"
      ],
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {}
    },
    "responses_answers_choicetables_choices": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "element_id",
        "row_id",
        "choice_id"
      ],
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {}
    },
    "responses_answers_rankings": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "element_id"
      ],
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {}
    },
    "responses_answers_rankings_ranked": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "element_id",
        "choice_id"
      ],
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {}
    },
    "responses_answers_rankings_notapplicable": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "element_id",
        "choice_id"
      ],
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {}
    },
    "responses_answers_inputs": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "element_id",
        "input_id"
      ],
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {}
    },
    "responses_answers_inputtables": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "element_id",
        "row_id"
      ],
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {}
    },
    "responses_answers_inputtables_columns": {
      "endpoint": "surveys/{survey_id}/responses/{response_id}",
      "unique_identifier": [
        "response_id",
        "element_id",
        "row_id",
        "column_id"
      ],
      "unravel_properties": {},
      "lists_obj_after_unravel": [],
      "header_identifiers": [
        [
          "survey_id",
          "survey_id"
        ]
      ],
      "rename_cols": {}
    }
  }
}'
WHERE [IntegrationName] = N'SurveyHero001';
GO
