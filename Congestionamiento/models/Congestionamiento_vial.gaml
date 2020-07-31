/***
* Name: Congestionamientovial
* Author: gamaa
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model Congestionamientovial

/* Insert your model definition here */

global{
	int width parameter:"width" category:"Simulacion" <- 50;
	int numero_semaforos parameter:"Numero de semaforos" category:"Simulation" <- 1 min:0 max:10;
	int tiempo_semaforo parameter:"Tiempo de semaforo" category:"Simulacion" <- 10 min:1 max:50;
	int numero_autos parameter:"Numero de autos" category:"Simulation" <- 10 min:0 max:50;
	geometry shape <- rectangle(width*15,20);
	init{
		create car number:numero_autos;
		loop times:numero_semaforos{
			ask one_of(cells where(each.semaforo=false)){
				semaforo <- true;
			}
		}
	}
	reflex actualizar_semaforos when:every(tiempo_semaforo#cycle){
		ask cells where(each.semaforo = true){
			permitir_paso <- permitir_paso=true?false:true;
		}
	}
}
grid cells width:width height:1 parallel:true{
	bool semaforo;
	bool permitir_paso;
	bool ocupado;
	map<bool,rgb> color_semaforo <- [true::#green,false::#red];
	init{
		semaforo <- false;
		permitir_paso <- true;
		ocupado <- false;
	}
	aspect default{
		draw shape color:semaforo?color_semaforo[permitir_paso]:#gray border:#black;
	}
}
species car skills:[moving]{
	list<cells> celdas_vecinas;
	cells celda_actual;
	cells celda_siguiente;
	rgb car_color;
	
	init{
		cells inicial <- one_of(cells where(each.ocupado=false));
		location <- inicial.location;
		inicial.ocupado <- true;
		car_color <- #yellow;
	}
	aspect default{
		draw circle(5) color:car_color;
	}
	reflex manejar{
		celda_actual <- cells closest_to self.location;
		celdas_vecinas <- celda_actual neighbors_at 1;
		
		if celda_actual = cells[0]{
			celda_siguiente <- cells[1];
		}
		else if celda_actual = cells[width-1]{
			celda_siguiente <- cells[0];
		}
		else {
			celda_siguiente <- celdas_vecinas[1];
		}
		if celda_siguiente.ocupado = false and celda_siguiente.permitir_paso = true{
			celda_actual.ocupado <- false;
			celda_siguiente.ocupado <- true;
			location <- celda_siguiente.location;
		}
	}
}
experiment trafico type:gui{
	output{
		display simulacion type:opengl draw_env:false{
			species cells aspect:default;
			species car aspect:default;
		}
	}
}