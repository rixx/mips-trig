#include<stdio.h>
#include<math.h>

float rixxsin(float);
float rixxcos(float);
float rixxtan(float);
float rixxsin0(float);
float rixxtan0(float);

int MAX_ITER = 5;

int main() {
    int n;
    float x_min, x_max, intervall, step;

    printf("Please enter x_min: ");
    scanf("%f", &x_min);

    printf("Please enter x_max: ");
    scanf("%f", &x_max);

    printf("Please enter n: ");
    scanf("%d", &n);

    intervall = (x_max - x_min) / (n - 1);

    if (intervall < 0){
        printf("x_min must be smaller than x_max!");
        return -1;
    }

    for (step = x_min; n > 0; n--, step += intervall) {
        float sinus, cosinus, tangens;

        sinus = rixxsin(step);
        cosinus = rixxcos(step);
        tangens = rixxtan(step);


        printf("%5f | sin %8f (%8f) | cos %8f (%8f) | tan %8f (%8f)\n", 
                   step, sinus, sinus - sin(step), cosinus, cosinus - cos(step),
                   tangens, tangens - tan(step));
    }

    return 0;
}


float rixxsin(float x) {
    while (x < -M_PI) {
       x += 2*M_PI;
    }

    while (x > M_PI) {
       x -= 2*M_PI;
    }

    if (x < -M_PI/2) {
        return -rixxsin0(x + M_PI);
    } else if (x > M_PI/2) {
        return -rixxsin0(x - M_PI);
    } else {
        return rixxsin0(x);
    }
}

float rixxsin0(float x) {
    int i, fac = 1;
    float pow = x, result = x;

    for (i = 1; i < MAX_ITER; i++) {
        pow *= x * x;
        fac *= (2 * i) * (2 * i + 1);
        result -= (pow/fac);
        i++;

        pow *= x * x;
        fac *= (2 * i) * (2 * i + 1);
        result += (pow/fac);
    }
    
    return result;
}


float rixxcos(float x) {
    return rixxsin(M_PI/2 - x);
}

float rixxtan(float x) {
    while (x < -M_PI/2) {
        x += M_PI;
    }

    while (x > M_PI/2) {
        x -= M_PI;
    }
    
    if ((x == M_PI/2) || (x == -M_PI/2)) {
        return 2;
    } else {
        return rixxtan0(x);
    }
}

float rixxtan0(float x) {
    float cosinus, sinus = rixxsin0(x);
    float cos_x = M_PI/2 - x;

    if (cos_x > M_PI/2) {
        cosinus = -rixxsin0(cos_x - M_PI);
    } else {
        cosinus = rixxsin0(cos_x);
    }

    return sinus / cosinus;
}
