# Simple python tool to conver a openapispec.yaml to a js file of express routes

# yaml struct:
# openapi: 3.0.3
# info: dont care
# paths: all the stuff we care about
#   /path:
#     parameters: for query or path params
#      - name: name
#        in: query or path
#        description: put in docstring
#        schema: put in docstring
#        example: put in docstring
#        required: true or false
#     type: post, get, etc
#         summary: put in docstring
#         description: put in docstring
#         operationId: put in docstring
#         tags: put in associated file
#         responses: status codes and descriptions, create a empty if else block for each
#             description: put inside the if else block
# components: for schemas, dont care
# tags: for grouping, read first

reqtypes = ['get', 'post', 'patch', 'delete'] # uses patch instead of put

#for every tag, create a file named tag.js and put its description in a comment at the top
output = './output/'
input = './tarpaulin_openapi_spec.yml'

import os
import yaml

yml = yaml.load(open(input, 'r'), Loader=yaml.FullLoader)

print(yml)

# create output directory
if not os.path.exists(output):
    os.makedirs(output)

for tag in yml['tags']:
    with open(output + tag['name'] + '.js', 'w') as f:
        f.write('/* ' + tag['description'] + ' */\n')

for path in yml['paths']:
    for reqtype in reqtypes:
        if reqtype in yml['paths'][path]:
            with open(output + yml['paths'][path][reqtype]['tags'][0] + '.js', 'a') as f:
                f.write('\n\n/**\n * ' + yml['paths'][path][reqtype]['summary'] + '\n * ' + yml['paths'][path][reqtype]['description'] + '\n */\n')
                f.write('app.' + reqtype + '(\'' + path + '\', (req, res) => {\n\n')
                first = True
                for status in yml['paths'][path][reqtype]['responses']:
                    if first:
                        f.write('    // Status code: ' + status + '\n')
                        f.write('    if (/* condition */) {\n')
                        first = False
                    else:
                        f.write('    } else if (/* condition */) {\n')
                        f.write('        // Status code: ' + status + '\n')
                f.write('    } else {\n')
                f.write('        // unknown error\n')
                f.write('    }\n')
                f.write('    res.send()\n')
                f.write('    res.end()\n')
                f.write('    return\n')
                f.write('})\n\n')

print('done')