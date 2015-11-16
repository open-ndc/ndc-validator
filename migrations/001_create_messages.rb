Sequel.migration do

	change do
		create_table :messages do
			String :hash_id, size: 32, primary_key: true
			Datetime :created_at
			String :name, text: true, size: 48
			String :ndc_method, text: true, size: 20
			String :ndc_errors, text: true
			String :xml, text: true
			String :notes, text: true
		end
	end

end
