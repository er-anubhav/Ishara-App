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
					'REMAINDERS'
				];
	}

	public function profileFolderName($profile_id = 0)
	{
		$hex = 'PROFILE'.$profile_id;

		return strtoupper(base_convert($hex, 36, 32));
	}
}