import { createRouter } from '@backstage/plugin-app-backend';
import { Router } from 'express';
import { PluginEnvironment } from '../types';

export default async function createPlugin({
  logger,
  config,
}: PluginEnvironment): Promise<Router> {
  return await createRouter({
    logger,
    config,
    // Using absolute path to peer app package to allow bundling to work
    appPackageName: `${process.cwd()}/packages/app`,
  });
}
