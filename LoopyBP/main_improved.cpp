#include <iostream>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgcodecs/imgcodecs.hpp>
#include <string>
#include <vector>

/* The following files are the input of this program and should be store in
 * DIRECTORY: input.png; 1.png, 2.png, ..., 13.png */

enum DIRECTION { LEFT, RIGHT, UP, DOWN, DATA };

// parameters, specific to dataset
const int BP_ITERATIONS = 40;
const int LABELS = 13;
const int LAMBDA = 10;
const std::string DIRECTORY = "../Datasets/Current/topk";

struct Pixel {
  // Each pixel has 5 'message box' to store incoming data
  unsigned msg[5][LABELS];
  int best_assignment;
};

struct MRF2D {
  std::vector<Pixel> grid;
  int width, height;
};

// Application specific code
void InitDataCost(const std::vector<cv::Mat> &imgs, MRF2D &mrf);
unsigned DataCost(const std::vector<cv::Mat> &imgs, int x, int y, int label);
unsigned SmoothnessCost(const std::vector<cv::Mat> &imgs, int x, int y, int i,
                        int j, DIRECTION direction);

// Loppy belief propagation specific
void BP(const std::vector<cv::Mat> &imgs, MRF2D &mrf, DIRECTION direction);
void SendMsg(const std::vector<cv::Mat> &imgs, MRF2D &mrf, int x, int y,
             DIRECTION direction);
unsigned MAP(const std::vector<cv::Mat> &imgs, MRF2D &mrf);

int main() {
  std::vector<cv::Mat> imgs(LABELS);
  for (int i = 0; i < LABELS; i++) {
    std::string file = DIRECTORY + std::to_string(i + 1) + ".png";
    imgs[i] = cv::imread(file.c_str(), 1);
    if (!imgs[i].data) {
      std::cerr << "Error reading image " << i + 1 << std::endl;
      exit(1);
    }
  }
  assert(imgs[0].channels() == 3);

  MRF2D mrf;

  InitDataCost(imgs, mrf);

  for (int i = 0; i < BP_ITERATIONS; i++) {
    BP(imgs, mrf, RIGHT);
    BP(imgs, mrf, LEFT);
    BP(imgs, mrf, UP);
    BP(imgs, mrf, DOWN);

    unsigned energy = MAP(imgs, mrf);

    std::cout << "iteration " << (i + 1) << "/" << BP_ITERATIONS
         << ", energy = " << energy << std::endl;
  }

  cv::Mat output = cv::Mat::zeros(mrf.height, mrf.width, CV_8UC3);

  for (int y = 0; y < mrf.height; y++) {
    for (int x = 0; x < mrf.width; x++) {
      int assignment = mrf.grid[y * mrf.width + x].best_assignment;
      output.at<cv::Vec3b>(y, x) = imgs[assignment].at<cv::Vec3b>(y, x);
    }
  }

  /*
  cv::namedWindow("main", CV_WINDOW_AUTOSIZE);
  cv::imshow("main", output);
  cv::waitKey(0);
  */

  std::cout << "Saving results to output.png" << std::endl;
  cv::imwrite(DIRECTORY + "output_improved.png", output);

  return 0;
}

unsigned DataCost(const std::vector<cv::Mat> &imgs, int x, int y, int label) {
  cv::Vec3b curr = imgs[label].at<cv::Vec3b>(y, x);
  unsigned cost = 0;

  /*
  // Sum-of-square-differences data cost
  for (int i = 0; i < LABELS; i++) {
    cv::Vec3b other = imgs[i].at<cv::Vec3b>(y, x);
    for (int rgb = 0; rgb < 3; rgb++) {
      cost += (curr.val[rgb] - other.val[rgb]) *
              (curr.val[rgb] - other.val[rgb]) / (LABELS * 3);
    }
  }
  return cost;
  */

  // Median-based data cost
  cv::Vec3b median;
  for (int rgb = 0; rgb < 3; rgb++) {
    std::vector<unsigned> data(LABELS);
    for (int i = 0; i < LABELS; i++) {
      data[i] = imgs[i].at<cv::Vec3b>(y, x).val[rgb];
    }
    sort(data.begin(), data.end());
    median.val[rgb] = data[(LABELS + 1) / 2];
  }
  for (int rgb = 0; rgb < 3; rgb++) {
    cost += abs(curr.val[rgb] - median.val[rgb]) / 3;
  }
  return cost;
}

unsigned SmoothnessCost(const std::vector<cv::Mat> &imgs, int x, int y, int i,
                        int j, DIRECTION direction) {
  // Label-based smoothness cost
  // return i == j ? 0 : LAMBDA;

  // Value-based smoothness cost
  unsigned cost = 0;
  for (int rgb = 0; rgb < 3; rgb++) {
    unsigned x_i = imgs[i].at<cv::Vec3b>(y, x).val[rgb];

    unsigned x_j;
    switch (direction) {
      case LEFT:
        x_j = imgs[j].at<cv::Vec3b>(y, x - 1).val[rgb];
        break;

      case RIGHT:
        x_j = imgs[j].at<cv::Vec3b>(y, x + 1).val[rgb];
        break;

      case UP:
        x_j = imgs[j].at<cv::Vec3b>(y - 1, x).val[rgb];
        break;

      case DOWN:
        x_j = imgs[j].at<cv::Vec3b>(y + 1, x).val[rgb];
        break;

      default:
        assert(0);
        break;
    }

    cost += (x_i - x_j) * (x_i - x_j) / 3;
  }
  return cost / LAMBDA;
}

void InitDataCost(const std::vector<cv::Mat> &imgs, MRF2D &mrf) {
  // Cache the data cost results so we don't have to recompute it every time

  mrf.width = imgs[0].cols;
  mrf.height = imgs[0].rows;

  int total = mrf.width * mrf.height;

  mrf.grid.resize(total);

  // Initialize all messages to zero
  for (int i = 0; i < total; i++) {
    for (int j = 0; j < 5; j++) {
      for (int k = 0; k < LABELS; k++) {
        mrf.grid[i].msg[j][k] = 0;
      }
    }
  }

  for (int y = 0; y < mrf.height; y++) {
    for (int x = 0; x < mrf.width; x++) {
      for (int i = 0; i < LABELS; i++) {
        mrf.grid[y * imgs[0].cols + x].msg[DATA][i] = DataCost(imgs, x, y, i);
      }
    }
  }
}

void SendMsg(const std::vector<cv::Mat> &imgs, MRF2D &mrf, int x, int y,
             DIRECTION direction) {
  unsigned new_msg[LABELS];

  int width = mrf.width;

  for (int i = 0; i < LABELS; i++) {
    unsigned min_val = UINT_MAX;

    for (int j = 0; j < LABELS; j++) {
      unsigned p = 0;

      p += SmoothnessCost(imgs, x, y, i, j, direction);
      p += mrf.grid[y * width + x].msg[DATA][j];

      // Exclude the incoming message direction that we are sending to
      if (direction != LEFT) p += mrf.grid[y * width + x].msg[LEFT][j];
      if (direction != RIGHT) p += mrf.grid[y * width + x].msg[RIGHT][j];
      if (direction != UP) p += mrf.grid[y * width + x].msg[UP][j];
      if (direction != DOWN) p += mrf.grid[y * width + x].msg[DOWN][j];

      min_val = std::min(min_val, p);
    }

    new_msg[i] = min_val;
  }

  for (int i = 0; i < LABELS; i++) {
    switch (direction) {
      case LEFT:
        mrf.grid[y * width + x - 1].msg[RIGHT][i] = new_msg[i];
        break;

      case RIGHT:
        mrf.grid[y * width + x + 1].msg[LEFT][i] = new_msg[i];
        break;

      case UP:
        mrf.grid[(y - 1) * width + x].msg[DOWN][i] = new_msg[i];
        break;

      case DOWN:
        mrf.grid[(y + 1) * width + x].msg[UP][i] = new_msg[i];
        break;

      default:
        assert(0);
        break;
    }
  }
}

void BP(const std::vector<cv::Mat> &imgs, MRF2D &mrf, DIRECTION direction) {
  int width = mrf.width;
  int height = mrf.height;

  switch (direction) {
    case RIGHT:
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width - 1; x++) {
          SendMsg(imgs, mrf, x, y, direction);
        }
      }
      break;

    case LEFT:
      for (int y = 0; y < height; y++) {
        for (int x = width - 1; x >= 1; x--) {
          SendMsg(imgs, mrf, x, y, direction);
        }
      }
      break;

    case DOWN:
      for (int x = 0; x < width; x++) {
        for (int y = 0; y < height - 1; y++) {
          SendMsg(imgs, mrf, x, y, direction);
        }
      }
      break;

    case UP:
      for (int x = 0; x < width; x++) {
        for (int y = height - 1; y >= 1; y--) {
          SendMsg(imgs, mrf, x, y, direction);
        }
      }
      break;

    case DATA:
      assert(0);
      break;
  }
}

unsigned MAP(const std::vector<cv::Mat> &imgs, MRF2D &mrf) {
  // Finds the MAP assignment as well as calculating the energy

  // MAP assignment
  for (size_t i = 0; i < mrf.grid.size(); i++) {
    unsigned best = std::numeric_limits<unsigned>::max();
    for (int j = 0; j < LABELS; j++) {
      unsigned cost = 0;

      cost += mrf.grid[i].msg[LEFT][j];
      cost += mrf.grid[i].msg[RIGHT][j];
      cost += mrf.grid[i].msg[UP][j];
      cost += mrf.grid[i].msg[DOWN][j];
      cost += mrf.grid[i].msg[DATA][j];

      if (cost < best) {
        best = cost;
        mrf.grid[i].best_assignment = j;
      }
    }
  }

  int width = mrf.width;
  int height = mrf.height;

  // Energy
  unsigned energy = 0;

  for (int y = 0; y < mrf.height; y++) {
    for (int x = 0; x < mrf.width; x++) {
      int cur_label = mrf.grid[y * width + x].best_assignment;

      // Data cost
      energy += mrf.grid[y * width + x].msg[DATA][cur_label];

      if (x - 1 >= 0)
        energy +=
            SmoothnessCost(imgs, x, y, cur_label,
                           mrf.grid[y * width + x - 1].best_assignment, LEFT);
      if (x + 1 < width)
        energy +=
            SmoothnessCost(imgs, x, y, cur_label,
                           mrf.grid[y * width + x + 1].best_assignment, RIGHT);
      if (y - 1 >= 0)
        energy +=
            SmoothnessCost(imgs, x, y, cur_label,
                           mrf.grid[(y - 1) * width + x].best_assignment, UP);
      if (y + 1 < height)
        energy +=
            SmoothnessCost(imgs, x, y, cur_label,
                           mrf.grid[(y + 1) * width + x].best_assignment, DOWN);
    }
  }

  return energy;
}
