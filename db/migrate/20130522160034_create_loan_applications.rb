class CreateLoanApplications < ActiveRecord::Migration
  # def change
  #   create_table :loan_applications do |t|
  #     t.timestamps
  #   end
  # end

  def up
    create_table :loan_applications do |t|
      t.integer :user_id
      t.decimal :loan_ammount
      t.integer :terms
      t.string :ssn
      t.string :postal_code
      t.string :address
      t.string :state
      t.timestamps
    end
  end

  def down
    drop_table :loan_applications
  end
end
