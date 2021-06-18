const { getParam } = require('../index');

describe('Key Rotation and Generation', () => {
  it('should retrieve url value from ssm', async () => {
    const parameterPath = `/repo/${process.env.NHS_ENVIRONMENT}/output/prm-deductions-gp2gp-adaptor/service-url`
    const expectedParameterValue = `https://gp2gp-adaptor.${process.env.NHS_ENVIRONMENT}.non-prod.patient-deductions.nhs.uk`;
    const res = await getParam(parameterPath);

    expect(res.Parameter.Value).toBe(expectedParameterValue)
  })
})

