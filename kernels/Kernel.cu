#include "Kernel.cuh"
#include <cmath>

typedef struct RGB {
	uint8_t r;
	uint8_t g; 
	uint8_t b; 
	uint8_t a; 
}RGB;







__device__
uint32_t rgb_to_int(RGB val,  bool isBigEndian ) {
		uint32_t value = (isBigEndian) ? val.a | (val.b << 8) | (val.g << 16) | (val.r << 24) : val.r | (val.g << 8) | (val.b << 16) | (val.a << 24);
		return value;
			 	
	

}


__device__
void initialize_2D_array(uint32_t *array, int size_w, int size_h) {
	int i = blockIdx.x;
	int j = threadIdx.x;

	array[i*size_w + j] = 0;
}






 

 __global__
	 void GPU_compute_greyscale_luminance(void *array, int size_w, int size_h, const bool isbigEndian, const int bpp, int pitch) {
	 int i = blockIdx.x ;
	 int j = blockIdx.y ;
	 RGB rgb = { 0 , 0 , 0 , 0 };
	 if (i < size_w && j < size_h) {
		 uint8_t* pixel_value = (uint8_t*) (array)+i*bpp + j*pitch;

		 if (bpp == 4) {
			 if (isbigEndian) {
				 rgb.r = *pixel_value >> 24 & 0xFF;
				 rgb.g = *pixel_value >> 16 & 0xFF;
				 rgb.b = *pixel_value >> 8 & 0xFF;
				 rgb.a = *pixel_value & 0xFF;
			 }
			 else {
				 rgb.a = *pixel_value >> 24 & 0xFF;
				 rgb.b = *pixel_value >> 16 & 0xFF;
				 rgb.g = *pixel_value >> 8 & 0xFF;
				 rgb.r = *pixel_value & 0xFF;
			 }
			 rgb.r = (rgb.r + rgb.b + rgb.g) / 3;
			 rgb.g = rgb.r;
			 rgb.b = rgb.r;
			 uint32_t toInt = rgb_to_int(rgb, isbigEndian);
			 *(uint32_t*)(pixel_value) = toInt;
			   

		 }
		 else if (bpp == 3) {
			 if (isbigEndian) {
				 rgb.r = *pixel_value >> 16 & 0XFF;
				 rgb.g = *pixel_value >> 8 & 0XFF;
				 rgb.b = *pixel_value & 0XFF;
				 rgb.a = 0; 				
				 rgb.r = (rgb.r + rgb.b + rgb.g) / 3;
				 rgb.g = rgb.r;
				 rgb.b = rgb.r;
				 uint32_t toInt = rgb_to_int(rgb, isbigEndian);
				 ((uint8_t*)pixel_value)[0] = toInt >> 16 & 0xFF;
				 ((uint8_t*)pixel_value)[1] = toInt >> 8 & 0xFF;
				 ((uint8_t*)pixel_value)[2] = toInt & 0xFF;

			 }
			 else {
				 rgb.b = *pixel_value >> 16 & 0XFF;
				 rgb.g = *pixel_value >> 8 & 0XFF;
				 rgb.r = *pixel_value & 0XFF;
				 rgb.a = 0;
				 rgb.r = (rgb.r + rgb.b + rgb.g) / 3;
				 rgb.g = rgb.r;
				 rgb.b = rgb.r;
				 uint32_t toInt = rgb_to_int(rgb, isbigEndian);
				 ((uint8_t*)pixel_value)[0] = toInt & 0xFF;
				 ((uint8_t*)pixel_value)[1] = toInt >> 8 & 0xFF;
				 ((uint8_t*)pixel_value)[2] = toInt >> 16 & 0xFF;
			 }
			   
		 }
		 else if (bpp == 2) {
			 if (isbigEndian) {
				 rgb.r = *pixel_value >> 12 & 0xF;
				 rgb.g = *pixel_value >> 8 & 0XF;
				 rgb.b = *pixel_value >> 4 & 0XF;
				 rgb.a = *pixel_value & 0XF;
			 }
			 else {
				 rgb.a = *pixel_value >> 12 & 0xF;
				 rgb.b = *pixel_value >> 8 & 0XF;
				 rgb.g = *pixel_value >> 4 & 0XF;
				 rgb.r = *pixel_value & 0XF;
			 }
			 rgb.r = (rgb.r + rgb.b + rgb.g) / 3;
			 rgb.g = rgb.r;
			 rgb.b = rgb.r;
			 uint32_t toInt = rgb_to_int(rgb, isbigEndian);
			 *((uint16_t*)pixel_value) = toInt;
			   
		 }
		 else if (bpp == 1) {
			 if (isbigEndian) {
				 rgb.r = *pixel_value >> 5 & 0X7;
				 rgb.g = *pixel_value >> 2 & 0X7;
				 rgb.b = *pixel_value & 0X3;
				 rgb.a = 0;
			 }
			 else {
				 rgb.b = *pixel_value >> 5 & 0X7;
				 rgb.g = *pixel_value >> 2 & 0X7;
				 rgb.r = *pixel_value & 0X3;
				 rgb.a = 0;
			 }
			 uint8_t grayscale = (rgb.r + rgb.b + rgb.g) / 3;
			  rgb.r = grayscale;
			  rgb.g = grayscale;
			  rgb.b = grayscale;
			  uint32_t toInt = rgb_to_int(rgb, isbigEndian);
				  *pixel_value = toInt;
				    
			
		 }


	 }

 }

 









 void GPU_compute_greyscale(SDL_Surface* image,  const bool bigEndian) {
	 int width = image->w; 
	 int height = image->h; 
	 int pitch = image->pitch; 
	 int bpp = image->format->BytesPerPixel; 
	 
	 void* D_image; 
	 size_t size = pitch * height; 

	 cudaMalloc((void**)&D_image, size); 
	 
	 cudaMemcpy(D_image, image->pixels, size, cudaMemcpyHostToDevice);
	 int threads = 1;
	 dim3 blocks_per_grid = dim3(width , height);
	 GPU_compute_greyscale_luminance << <blocks_per_grid, threads >> > (D_image, width, height, bigEndian, bpp, pitch);
	 SDL_LockSurface(image); 
	 cudaMemcpy(image->pixels, D_image, size, cudaMemcpyDeviceToHost);

	 SDL_UnlockSurface(image); 
	
	 cudaFree(D_image); 
 }




 __global__
	 void GPU_compute_hmap(uint32_t *array, int size_w, int size_h) {
	 initialize_2D_array(array, size_w, size_h);


 }