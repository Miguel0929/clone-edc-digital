class AddSentCertificateToProgramStats < ActiveRecord::Migration
	def change
		add_column :program_stats, :sent_certificate, :boolean, :default => false
	end
end
