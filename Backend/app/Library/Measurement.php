<?php

namespace App\Library;

trait Measurement{

	public function measurementsCategories()
	{
		return [
					'BP',
					'Pulse',
					'Weight',
					'Sugar',
				];
	}

}