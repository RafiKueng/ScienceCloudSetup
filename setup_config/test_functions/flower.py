import unittest
import requests as rq

url = "http://google.com"

class LoadBalancerTest(unittest.TestCase):

    def setUp(self):
        self.r = rq.get(url)

    def tearDown(self):
        pass

    
    def test_if_200(self):
        self.assertEqual(self.r.status_code, 200,
                         "statuscode is not 200")


if __name__ == '__main__':
    unittest.main()
