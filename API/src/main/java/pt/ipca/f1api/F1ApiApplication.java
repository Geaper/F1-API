package pt.ipca.f1api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.RequestMapping;

@SpringBootApplication
public class F1ApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(F1ApiApplication.class, args);
    }
}
