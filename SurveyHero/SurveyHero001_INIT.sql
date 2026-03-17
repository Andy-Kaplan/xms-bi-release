USE [core]
GO

DECLARE	@return_value int

EXEC	@return_value = [core].[AddIntegration]
		@IntegrationName = N'SurveyHero001',
		@IntegrationDisplayName = N'Survey Hero Version 1'

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
				"surveys": ["explode"]
			},
			"lists_obj_after_unravel": [],
			"header_identifiers": [],
			"rename_cols": {}
		},
		"survey_details": {
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
				"elements": ["explode"]
			},
			
			"lists_obj_after_unravel": [],
			
			"header_identifiers": [
				["survey_id", "survey_id"]
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
				"elements": ["explode"],
				"question": ["unnest"]
			},

			"lists_obj_after_unravel": [],

			"header_identifiers": [
				["survey_id", "survey_id"],
				["elements_element_id", "element_id"]
			],

			"rename_cols": {
				"type": "question_type",
				"text": "question_text",
				"description": "description_text",
				"settings.is_required": "settings_is_required"
			}
		},
		"elements_choice_lists": {
			"endpoint": "surveys/{survey_id}/elements",
			"unique_identifier": ["survey_id", "element_id"],
			"unravel_properties": {
				"elements": ["explode"],
				"question": ["unnest"],
				"choice_list": ["unnest"],
				"settings": ["unnest"]
			},
			"lists_obj_after_unravel": [],
			
			"header_identifiers": [
				["survey_id", "survey_id"],
				["element_id", "element_id"]
			],
			
			"rename_cols": {
				"allows_multiple_choices": "settings_allows_multiple_choices",
				"min_number_of_choices": "settings_min_number_of_choices",
				"max_number_of_choices": "settings_max_number_of_choices"
			}
		},
		"elements_choice_list_choices": {
			"endpoint": "surveys/{survey_id}/elements",
			"unique_identifier": ["element_id", "choice_id"],

			"unravel_properties": {
				"elements": ["explode"],
				"question": ["unnest"],
				"choice_list": ["unnest"],
				"choices": ["explode", "unnest"]
			},

			"lists_obj_after_unravel": [],

			"header_identifiers": [
				["survey_id", "survey_id"],
				["elements_element_id", "element_id"]
			],

			"rename_cols": {
				"id": "choice_id"
			}
		},
		"elements_choice_tables": {
			"endpoint": "surveys/{survey_id}/elements",
			"unique_identifier": ["survey_id", "element_id"],
			"unravel_properties": {
				"elements": ["explode"],
				"question": ["unnest"],
				"choice_table": ["unnest"],
				"settings": ["unnest"]
			},
			"lists_obj_after_unravel": [],
			
			"header_identifiers": [
				["survey_id", "survey_id"],
				["element_id", "element_id"]
			],
			
			"rename_cols": {
				"allows_multiple_choices_per_row": "settings_allows_multiple_choices_per_row"
			}
		},
	}
}'
,
[IntegrationType] = 'SURVEY'

WHERE [IntegrationName] = 'SurveyHero001'