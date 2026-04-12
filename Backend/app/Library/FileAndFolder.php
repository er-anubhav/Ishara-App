<?php

namespace App\Library;

trait FileAndFolder{

	public function fileCategories()
	{
		return [
					'TEST_REPORTS',
					'DOCTOR_PRESCRIPTION',
					'DAILY_MEASUREMENTS',
					'HOSPITAL_BILLS',
					'PHARMACY_RECORDS',
					'GENERAL_DOCS',
					'REMAINDERS'
				];
	}

	public function fileStorageOnlyCategories()
	{
		return [
					['name' => 'Test Reports', 'value' => 'TEST_REPORTS', 'tag' => 'category'],
					['name' => 'Doctor Prescription', 'value' => 'DOCTOR_PRESCRIPTION', 'tag' => 'category'],
					['name' => 'General Docs', 'value' => 'GENERAL_DOCS', 'tag' => 'category'],
					['name' => 'Hospital Bills', 'value' => 'HOSPITAL_BILLS', 'tag' => 'category'],
					['name' => 'Pharmacy Records', 'value' => 'PHARMACY_RECORDS', 'tag' => 'category'],
				];
	}

	public function profileFolderName($profile_id = 0)
	{
		$hex = 'PROFILE'.$profile_id;

		return strtoupper(base_convert($hex, 36, 32));
	}
}