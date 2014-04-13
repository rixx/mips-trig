#include<stdio.h>
#include<math.h>

/* as specified */
float rixxsin(float);
float rixxcos(float);
float rixxtan(float);
float rixxsin0(float);
float rixxtan0(float);

/* maximum number of Taylor series terms */
int MAX_ITER = 5;

/* as specified: user is prompted for x_min, x_max and n
 * then for n equidistant values in [x_min, x_max], sin, cos and tan are printed
 * bonus feature: in brackets, the deviation from the real value
 */
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

    if (intervall < 0) {
        printf("x_min must be smaller than x_max and n larger than 1!");
        return -1;
    }

    /* start at x_min, do n steps */
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

/* takes any value x, normalizes into [-pi, pi], then calls rixxsin0 */
float rixxsin(float x) {
    /* normalizing */
    while (x < -M_PI) {
       x += 2*M_PI;
    }

    while (x > M_PI) {
       x -= 2*M_PI;
    }

    /* calling rixxsin0. minor modifications, since rixxsin0 is defined
     * for [-pi/2, pi/2] */
    if (x < -M_PI/2) {
        return -rixxsin0(x + M_PI);
    } else if (x > M_PI/2) {
        return -rixxsin0(x - M_PI);
    } else {
        return rixxsin0(x);
    }
}

/* computes the taylor series for sin(x):
 * sum((-1)^(n−1) * x^(2n - 1) / (2n - 1)!) */
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

/* cos(x) = sin(pi/2 - x) */
float rixxcos(float x) {
    return rixxsin(M_PI/2 - x);
}

/* for reasons, rixxtan is supposed to call rixxtan0, which may only take
 * values in ]-pi/2, pi/2[ */
float rixxtan(float x) {
    while (x < -M_PI/2) {
        x += M_PI;
    }

    while (x > M_PI/2) {
        x -= M_PI;
    }
    
    if ((x == M_PI/2) || (x == -M_PI/2)) {
        /* ok, this should be inf or nan, but wth … */
        return 2;
    } else {
        return rixxtan0(x);
    }
}

/* and this is just plain stupid -- rixxtan0 may only call rixxsin0,
 * but since tan = sin/cos, this needs to re-implement part of the 
 * rixxcos logic */
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
