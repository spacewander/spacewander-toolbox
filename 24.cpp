// 计算24点
#include <algorithm>
#include <climits>
#include <cstdio>
#include <cstdlib>
#include <cstring>

using namespace std;

#define OPS 4
enum OP {
    PLUS,
    SUB,
    MULTIPLY,
    DIVIDE,
};

char toOp(int op)
{
    switch (op)
    {
    case OP::PLUS:
        return '+';
    case OP::SUB:
        return '-';
    case OP::MULTIPLY:
        return '*';
    case OP::DIVIDE:
        return '/';
    default:
        fprintf(stderr, "Unknown op %d\n", op);
        exit(0);
    }
}

void fillOpResults(double left, double right, double result[], int ops[])
{
    // use INT_MAX to mean impossible
    if (left == INT_MAX || right == INT_MAX) {
        for (int i = 0; i < OPS; ++i) {
            result[i] = INT_MAX;
        }
        return;
    }
    result[0] = left + right;
    ops[0] = ops[0] * 10 + OP::PLUS;
    result[1] = left - right;
    ops[1] = ops[1] * 10 + OP::SUB;
    result[2] = left * right;
    ops[2] = ops[2] * 10 + OP::MULTIPLY;
    if (right)
        result[3] = left / right;
    else
        result[3] = INT_MAX;
    ops[3] = ops[3] * 10 + OP::DIVIDE;
}

// (a op b) op (c op d)
bool get24InParallel(int a, int b, int c, int d)
{
    enum Parentheses {
        NONE = 0,
        ONLY_LEFT,
        ONLY_RIGHT,
        BOTH,
    };

    double result[OPS*OPS][OPS];
    int ops[OPS*OPS][OPS];
    double internResult1[OPS];
    int internOps1[OPS] = {0};
    fillOpResults(a, b, internResult1, internOps1);
    double internResult2[OPS];
    int internOps2[OPS] = {0};
    fillOpResults(c, d, internResult2, internOps2);

    for (int i = 0; i < OPS; ++i) {
        for (int j = 0; j < OPS; ++j) {
            int internOps = internOps1[i] * 10 + internOps2[j];
            for (int k = 0; k < OPS; ++k) {
                ops[i*OPS+j][k] = internOps;
            }
            fillOpResults(internResult1[i], internResult2[j], 
                    result[i*OPS+j], ops[i*OPS+j]);
        }
    }
    for (int i = 0; i < OPS * OPS; ++i) {
        for (int j = 0; j < OPS; ++j) {
            if (result[i][j] == 24) {
                int op1 = ops[i][j] / 100; // 百位数
                int op2 = ops[i][j] % 10; // 个位数
                int op3 = (ops[i][j] % 100) / 10; // 十位数

                int parentheses = Parentheses::NONE;
                switch (op2)
                {
                case OP::DIVIDE:
                    parentheses |= Parentheses::ONLY_RIGHT;
                    if (op1 == OP::SUB || op1 == OP::PLUS) {
                        parentheses |= Parentheses::ONLY_LEFT;
                    }
                    break;
                case OP::MULTIPLY:
                    if (op1 == OP::SUB || op1 == OP::PLUS) {
                        parentheses |= Parentheses::ONLY_LEFT;
                    }
                    if (op3 != OP::MULTIPLY) {
                        parentheses |= Parentheses::ONLY_RIGHT;
                    }
                    break;
                case OP::SUB:
                    if (op3 == OP::PLUS) {
                        parentheses |= Parentheses::ONLY_RIGHT;
                    }
                    break;
                }

                switch (parentheses)
                {
                case Parentheses::BOTH:
                    printf("(%d %c %d) %c (%d %c %d)\n", a, toOp(op1), b, 
                            toOp(op2), c, toOp(op3), d);
                    break;
                case Parentheses::ONLY_LEFT:
                    printf("(%d %c %d) %c %d %c %d\n", a, toOp(op1), b, 
                            toOp(op2), c, toOp(op3), d);
                    break;
                case Parentheses::ONLY_RIGHT:
                    printf("%d %c %d %c (%d %c %d)\n", a, toOp(op1), b, 
                            toOp(op2), c, toOp(op3), d);
                    break;
                default:
                    printf("%d %c %d %c %d %c %d\n", a, toOp(op1), b, 
                            toOp(op2), c, toOp(op3), d);
                }
                return true;
            }
        }
    }
    return false;
}

// a op b op c op d
bool get24InSeries(int a, int b, int c, int d)
{
    double result[OPS*OPS][OPS];
    int ops[OPS*OPS][OPS];
    double internResult1[OPS];
    int internOps1[OPS] = {0};
    fillOpResults(a, b, internResult1, internOps1);

    double internResult2[OPS*OPS];
    int internOps2[OPS*OPS];
    for (int i = 0; i < OPS; ++i) {
        for (int j = 0; j < OPS; ++j) {
            internOps2[i*OPS+j] = internOps1[i];
        }
        fillOpResults(internResult1[i], c, internResult2 + i * OPS, 
                internOps2 + i * OPS);
    }

    for (int i = 0; i < OPS; ++i) {
        for (int j = 0; j < OPS; ++j) {
            for (int k = 0; k < OPS; ++k) {
                ops[i*OPS+j][k] = internOps2[i*OPS+j];
            }
            fillOpResults(internResult2[i*OPS+j], d, result[i*OPS+j], 
                    ops[i*OPS+j]);
        }
    }
    for (int i = 0; i < OPS * OPS; ++i) {
        for (int j = 0; j < OPS; ++j) {
            if (result[i][j] == 24) {
                int op1 = ops[i][j] / 100; // 百位数
                int op2 = (ops[i][j] % 100) / 10; // 十位数
                int op3 = ops[i][j] % 10; // 个位数
                // let '+', '-' be first level op(represended with +)
                // let '*', '/' be second level op(represended with *)
                // there are four kind of expressions which need parentheses:
                // 1. (a * b + c) * d
                // 2. (a + b + c) * d => op2 is + and op3 is *
                // 3. (a + b) * c + d
                // 4. (a + b) * c * d => op1 is + and op2 is *
                if ((op1 == OP::PLUS || op1 == OP::SUB) && 
                        (op2 == OP::MULTIPLY || op2 == OP::DIVIDE)) {
                    printf("(%d %c %d) %c %d %c %d\n", a, toOp(op1), b, 
                            toOp(op2), c, toOp(op3), d);
                }
                else if ((op2 == OP::PLUS || op2 == OP::SUB) &&
                        (op3 == OP::MULTIPLY || op3 == OP::DIVIDE)) {
                    printf("(%d %c %d %c %d) %c %d\n", a, toOp(op1), b, 
                            toOp(op2), c, toOp(op3), d);
                }
                else {
                    printf("%d %c %d %c %d %c %d\n", a, toOp(op1), b, 
                            toOp(op2), c, toOp(op3), d);
                }
                return true;
            }
        }
    }
    return false;
}

int main(int argc, char *argv[])
{
    if (argc != 5) {
        printf("用法： %s 1 2 3 4\n", argv[0]);
        return 1;
    }
    int input[4];
    for (int i = 0; i < 4; ++i) {
        input[i] = atoi(argv[i+1]);
        if (input[i] <= 0 || input[i] > 13) {
            fprintf(stderr, "输入数字要在1到13之间\n");
            return 1;
        }
    }

    do {
        if (get24InParallel(input[0], input[1], input[2], input[3]) || 
               get24InSeries(input[0], input[1], input[2], input[3])) {
            printf("Found\n");
            return 0;
        }
    } while (next_permutation(input, &input[3]));
    printf("Not Found\n");
    return 0;
}
