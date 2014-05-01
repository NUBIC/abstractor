Given /^patients with the following information exist$/ do |table|
  table.hashes.each_with_index do |patient_hash, i|
    patient = FactoryGirl.create(:patient, patient_id: i,
                                           mrd_pt_id: i,
                                           initial_mrd_pt_id: i,
                                           last_nm: patient_hash['Last Name'],
                                           first_nm: patient_hash['First Name'],
                                           gender_nm: patient_hash['Gender'],
                                           nmff_mrns: patient_hash['NMFF MRNS'],
                                           nmh_mrns: patient_hash['NMH MRNS'],
                                           birth_dts: Date.parse(patient_hash['Birth Date'])
                                )
    if patient_hash['Person ID']
      patient_xref = FactoryGirl.create(:patient_xref_cerner, patient_xref_id: i, patient_id: i, pat_id_in_src_int: patient_hash['Person ID'].to_i)
    end
    if patient_hash['Pat ID']
      patient_xref = FactoryGirl.create(:patient_xref_epic, patient_xref_id: i, patient_id: i, pat_id_in_src_txt: patient_hash['Pat ID'])
    end
  end
end

Then(/^there should be (\d+) patient$/) do |patient_count|
  Patient.count.should == patient_count.to_i
end
