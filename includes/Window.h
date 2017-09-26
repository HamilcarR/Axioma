#ifndef WINDOW_H
#define WINDOW_H
#include <string>
#include <SDL/SDL.h>
#include <SDL/SDL_image.h>

#include "images.h"
#include <thread> 
namespace maptomix{

struct thread_data; 


class Window 

	{

public:
	Window(const int width, const int height,const char* name);
	~Window();
        void display_image(SDL_Surface* image);
	void setEvent(SDL_Event &ev) {event = ev;}
        SDL_Renderer* getRenderer(){return renderer;};
	int getHeight(){return height;}
	int getWidth(){return width;}
	void loop (SDL_Surface* im); 
	void synchronize(); 	
	static void loop_thread(thread_data *data); 
private:

	int width;
	int height;
	std::string name;
	SDL_Window *m_window; 
	SDL_Renderer *renderer;
	SDL_Event event ; 
	SDL_Texture *texture;
	bool free_surface_texture;
//	std::thread t_sdl; 

};

}


#endif

