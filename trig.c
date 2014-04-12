#include<stdio.h>
#include<math.h>

float rixxsin(float);
float rixxcos(float);
float rixxtan(float);
float rixxsin0(float);
float rixxtan0(float);

int SIN_COUNT = 5;
int COS_COUNT = 5;
int TAN_COUNT = 5;


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
    while (x < -PI) {
       x += 2*PI;
    }

    while (x > PI) {
       x -= 2*PI;
    }

    if (x < -PI/2) {
        return -rixxsin0(x + PI);
    } else if (x > PI/2) {
        return -rixxsin0(x - PI);
    } else {
        return rixxsin0(x);
    }
}

float rixxsin0(float x) {
    return 0;
}


float rixxcos(float x) {
    return 0;
}

float rixxtan(float x) {
    return 0;
}
