package com.web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.web.service.CityService;

@RestController
public class CityController {

	@Autowired
	CityService ser;

	@GetMapping("/citiess")
	public String allCities() {
		return ser.getCities();
	}

	@PostMapping("/citiesssss")
	public String add(String city){
		return city;
	}

}
