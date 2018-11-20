package pt.ipca.f1api.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import pt.ipca.f1api.models.Circuit;
import pt.ipca.f1api.repositories.CircuitRepository;

import java.util.List;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping(value = "/api", produces = "application/json")
public class CircuitsController {

    @Autowired
    private CircuitRepository circuitRepository;

    @GetMapping("/circuits")
    public List<Circuit> getCircuits() {
        return circuitRepository.findAll();
    }
}
